Threadable.ApplicationUpdate = RL.Model.extend({
  id:             RL.attr('string'),
  organizationId: RL.attr('number'),
  action:         RL.attr('string'),
  target:         RL.attr('string'),
  targetId:       RL.attr('number'),
  actor:          RL.attr('string'),
  createdAt:      RL.attr('date'),
  payload:        RL.attr('object'),
});

Threadable.RESTAdapter.map("Threadable.Event", {
  primaryKey: "id"
});
