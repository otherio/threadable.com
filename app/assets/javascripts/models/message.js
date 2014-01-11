Covered.Message = RL.Model.extend({
  id:                RL.attr('number'),
  unique_id:         RL.attr('string'),
  from:              RL.attr('string'),
  subject:           RL.attr('string'),
  body:              RL.attr('string'),
  body_stripped:     RL.attr('string'),
  message_id_header: RL.attr('string'),
  references_header: RL.attr('string'),
  date_header:       RL.attr('date'),
  html:              RL.attr('string'),
  root:              RL.attr('string'),
  shareworthy:       RL.attr('string'),
  knowledge:         RL.attr('string'),
  created_at:        RL.attr('date'),
  parent_message_id: RL.attr('number'),

  conversation_id:   RL.attr('string'),
  organization_id:   RL.attr('string'),
  group_id:          RL.attr('string')
});

Covered.RESTAdapter.map("Covered.Message", {
  primaryKey: "slug"
});

