//= require "multify/core"
//= require "multify/backbone"
//= require "multify/request"
//= require "multify/session"
//= require "multify/templates"
//= require "multify/router"
//= require "multify/routes"
//= require_tree "./multify/views"
//= require "multify/user"
//= require "multify/project"
//= require "multify/projects"
//= require "multify/task"
//= require "multify/tasks"
//= require "multify/authentication"
}();


function FUCKINGAROUND(){

M.get('current_user') // new M.User({})
M.set('current_user', new M.User({}));

M.User
M.Project
M.Project.Collection

V('dashboard/left_panel/projects')


M.projects = new M.Project.Collection


};
