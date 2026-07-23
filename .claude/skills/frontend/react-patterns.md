# React patterns

## State: derive, don't duplicate

```tsx
// ☠ synced state — three sources of truth that will disagree
const [items, setItems] = useState<Item[]>([]);
const [total, setTotal] = useState(0);
const [hasItems, setHasItems] = useState(false);
useEffect(() => { setTotal(items.reduce((s, i) => s + i.price, 0)); }, [items]);
useEffect(() => { setHasItems(items.length > 0); }, [items]);

// ✔ one source of truth, everything else computed at render
const [items, setItems] = useState<Item[]>([]);
const total = items.reduce((s, i) => s + i.price, 0);
const hasItems = items.length > 0;
// wrap in useMemo ONLY if profiling shows this compute is hot
```

Most `useEffect`-sets-state code is derived state in disguise ("You Might
Not Need an Effect"). Further rules:

- Locate state at the lowest common owner; lift only when two components
  truly share it. Context/store only for app-wide concerns (auth, theme).
- Group state that changes together:

```tsx
// ☠ five useStates that must stay in sync
// ✔ one reducer modeling the actual states
type FormState =
  | { status: "editing"; draft: Draft; error?: string }
  | { status: "submitting"; draft: Draft }
  | { status: "success"; orderId: string };
const [state, dispatch] = useReducer(formReducer, initial);
```

- URL is state: filters, tabs, pagination live in search params so links,
  refresh, and back-button work:

```tsx
const [params, setParams] = useSearchParams();
const page = Number(params.get("page") ?? 1);
```

## Effects: synchronize with external systems only

```tsx
// ✔ legitimate effect: subscribe + cleanup, correct deps
useEffect(() => {
  const sub = socket.subscribe(`orders:${orderId}`, onUpdate);
  return () => sub.unsubscribe();          // cleanup mirrors setup, always
}, [orderId]);
```

```tsx
// ☠ race: slow response for the OLD id overwrites the new one
useEffect(() => {
  fetch(`/api/users/${id}`).then(r => r.json()).then(setUser);
}, [id]);

// ✔ last-request-wins via an ignore flag
useEffect(() => {
  let ignore = false;
  fetch(`/api/users/${id}`)
    .then(r => { if (!r.ok) throw new Error(`HTTP ${r.status}`); return r.json(); })
    .then(data => { if (!ignore) setUser(data); })
    .catch(err => { if (!ignore) setError(err); });
  return () => { ignore = true; };
}, [id]);
```

No dependency-array lint suppressions — if the deps feel wrong, the effect's
design is wrong.

## Data fetching: prefer the platform

Server components / loaders (Next.js, Remix) or a query cache (TanStack
Query, SWR) over hand-rolled `useEffect`+`fetch` — dedupe, retries, caching,
and race handling come free:

```tsx
const { data, isPending, error } = useQuery({
  queryKey: ["user", id],
  queryFn: () => api.getUser(id),
  staleTime: 60_000,
});

const save = useMutation({
  mutationFn: api.updateUser,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ["user", id] }),
});
```

## Component design

```tsx
// ✔ composition over configuration
<Card>
  <CardHeader title="Orders" action={<RefreshButton />} />
  <OrderTable rows={rows} />
</Card>
// ☠ <Card headerTitle="Orders" headerAction="refresh" showFooter footerButtons={[...]} />
```

- Props: accept the minimum; spread `...rest` only onto the underlying DOM
  element. If a component needs six booleans it wants to be two components
  or a state machine.
- Forms: uncontrolled + `FormData` (or a form library) for big forms;
  controlled inputs only for live-validated fields. Always `<label htmlFor>`.
- Error boundaries around every route/panel that fetches; skeletons sized to
  the real content to prevent layout shift:

```tsx
<ErrorBoundary fallback={<PanelError retry />}>
  <Suspense fallback={<OrderTableSkeleton rows={10} />}>
    <OrderPanel />
  </Suspense>
</ErrorBoundary>
```

- Lists: stable `key` from data identity (`order.id`), never array index
  when items can reorder/insert.
