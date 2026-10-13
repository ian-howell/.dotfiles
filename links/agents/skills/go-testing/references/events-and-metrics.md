# Fakes for Kubernetes Events and OTel metrics

## Kubernetes Events

- `record.NewFakeRecorder(n)` (from `k8s.io/client-go/tools/record`). Its `Events` channel
  receives strings formatted `"<Type> <Reason> <Message>"`.
- To assert exactly one event, `require.Len(t, recorder.Events, 1)` then read it with
  `<-recorder.Events`. To assert none, `assert.Empty(t, recorder.Events)`.

## OTel metrics

- Setup:
  `reader := otelsdk.NewManualReader()`
  `meter := otelsdk.NewMeterProvider(otelsdk.WithReader(reader)).Meter("test")`
  where `otelsdk` is `go.opentelemetry.io/otel/sdk/metric`. Check the module's `go.mod` already
  requires it, and copy a sibling test's pattern when one exists.
- Read values back:
  `var rm metricdata.ResourceMetrics`
  `require.NoError(t, reader.Collect(ctx, &rm))`
  then type-assert `rm.ScopeMetrics[0].Metrics[0].Data.(metricdata.Sum[int64])` and inspect
  `DataPoints`.
- Compare the whole label set with `attribute.NewSet(...)` against `DataPoints[0].Attributes`.
  An exact-set comparison also proves no unbounded dimensions (object names) slipped in.
- Build a fresh reader per subtest so counts don't leak between cases.
