Covered.Organization = DS.Model.extend({
  name:                 DS.attr('string'),
  slug:                 DS.attr('string'),
  description:          DS.attr('string'),
  subjectTag:           DS.attr('string'),
  emailAddressUsername: DS.attr('string'),
  createdAt:            DS.attr('date'),
  updatedAt:            DS.attr('date'),

  emailAddress:              DS.attr('string'),
  taskEmailAddress:          DS.attr('string'),
  formattedEmailAddress:     DS.attr('string'),
  formattedTaskEmailAddress: DS.attr('string'),

  groups:          DS.hasMany('group', {async:true}),
  conversations:   DS.hasMany('conversation', {async:true}),
  myConversations: DS.hasMany('conversation', {async:true})
});
