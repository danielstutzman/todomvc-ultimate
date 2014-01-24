Utils = require('./utils.coffee')

App =
  init: ->
    @ENTER_KEY = 13
    @todos = Utils.store("todos-jquery")
    @cacheElements()
    @bindEvents()
    @render()

  cacheElements: ->
    @todoTemplate = Handlebars.compile($("#todo-template").html())
    @footerTemplate = Handlebars.compile($("#footer-template").html())
    @$todoApp = $("#todoapp")
    @$header = @$todoApp.find("#header")
    @$main = @$todoApp.find("#main")
    @$footer = @$todoApp.find("#footer")
    @$newTodo = @$header.find("#new-todo")
    @$toggleAll = @$main.find("#toggle-all")
    @$todoList = @$main.find("#todo-list")
    @$count = @$footer.find("#todo-count")
    @$clearBtn = @$footer.find("#clear-completed")

  bindEvents: ->
    list = @$todoList
    @$newTodo.on "keyup", @create
    @$toggleAll.on "change", @toggleAll
    @$footer.on "click", "#clear-completed", @destroyCompleted
    list.on "change", ".toggle", @toggle
    list.on "dblclick", "label", @edit
    list.on "keypress", ".edit", @blurOnEnter
    list.on "blur", ".edit", @update
    list.on "click", ".destroy", @destroy

  render: ->
    @$todoList.html @todoTemplate(@todos)
    @$main.toggle !!@todos.length
    @$toggleAll.prop "checked", not @activeTodoCount()
    @renderFooter()
    Utils.store "todos-jquery", @todos

  renderFooter: ->
    todoCount = @todos.length
    activeTodoCount = @activeTodoCount()
    footer =
      activeTodoCount: activeTodoCount
      activeTodoWord: Utils.pluralize(activeTodoCount, "item")
      completedTodos: todoCount - activeTodoCount

    @$footer.toggle !!todoCount
    @$footer.html @footerTemplate(footer)

  toggleAll: ->
    isChecked = $(this).prop("checked")
    $.each App.todos, (i, val) ->
      val.completed = isChecked
    App.render()

  activeTodoCount: ->
    count = 0
    $.each @todos, (i, val) ->
      count++  unless val.completed
    count

  destroyCompleted: ->
    todos = App.todos
    l = todos.length
    todos.splice l, 1  if todos[l].completed  while l--
    App.render()
  
  # accepts an element from inside the `.item` div and
  # returns the corresponding todo in the todos array
  getTodo: (elem, callback) ->
    id = $(elem).closest("li").data("id")
    $.each @todos, (i, val) ->
      if val.id is id
        callback.apply App, arguments
        false

  create: (e) ->
    $input = $(this)
    val = $.trim($input.val())
    return  if e.which isnt App.ENTER_KEY or not val
    App.todos.push
      id: Utils.uuid()
      title: val
      completed: false
    $input.val ""
    App.render()

  toggle: ->
    App.getTodo this, (i, val) ->
      val.completed = not val.completed
    App.render()

  edit: ->
    $input = $(this).closest("li").addClass("editing").find(".edit")
    val = $input.val()
    $input.val(val).focus()

  blurOnEnter: (e) ->
    if e.which is App.ENTER_KEY
      e.target.blur()
      $(this).trigger "blur"

  update: ->
    val = $.trim($(this).removeClass("editing").val())
    App.getTodo this, (i) ->
      if val
        @todos[i].title = val
      else
        @todos.splice i, 1
      @render()

  destroy: ->
    App.getTodo this, (i) ->
      @todos.splice i, 1
      @render()

module.exports = App
