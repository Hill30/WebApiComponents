#global describe, beforeEach, module, inject, it, spyOn, expect, $ 
describe "uiScroll", ->
  "use strict"
  angular.module("ui.scroll.test", []).factory("myEmptyDatasource", ["$log", "$timeout", "$rootScope", (console, $timeout, $rootScope) ->
    current = undefined
    get = undefined
    loading = undefined
    revision = undefined
    get = (index, count, success) ->
      success []

    get: get
  ]).factory "myOnePageDatasource", ["$log", "$timeout", "$rootScope", (console, $timeout, $rootScope) ->
    current = undefined
    get = undefined
    loading = undefined
    revision = undefined
    get = (index, count, success) ->
      if index is 1
        success ["one", "two", "three"]
      else
        success []

    get: get
  ]
  sandbox = angular.element("<div/>")
  beforeEach module("ui.scroll")
  beforeEach module("ui.scroll.test")
  beforeEach ->
    angular.element(document).find("body").append sandbox = angular.element("<div/>")

  afterEach ->
    sandbox.remove()

  describe "empty source - basic setup", ->
    it "should bind to window \"scroll\" event", inject(($rootScope, $compile) ->
      spyOn $.fn, "bind"
      scroller = angular.element("<div ng-scroll=\"item in myEmptyDatasource\">{{$index}}: {{item}}</div>")
      sandbox.append scroller
      $compile(scroller) $rootScope
      $rootScope.$apply()
      expect($.fn.bind).toHaveBeenCalled()
      expect($.fn.bind.mostRecentCall.args[0]).toBe "scroll"
      expect($.fn.bind.mostRecentCall.object[0]).toBe window
    )
    it "should create 2 divs of 0 height", inject(($rootScope, $compile) ->
      scroller = angular.element("<div ng-scroll=\"item in myEmptyDatasource\">{{$index}}: {{item}}</div>")
      sandbox.append scroller
      $compile(scroller) $rootScope
      $rootScope.$apply()
      expect(sandbox.children().length).toBe 2
      topPadding = sandbox.children()[0]
      expect(topPadding.tagName.toLowerCase()).toBe "div"
      expect(angular.element(topPadding).css("height")).toBe "0px"
      bottomPadding = sandbox.children()[1]
      expect(bottomPadding.tagName.toLowerCase()).toBe "div"
      expect(angular.element(bottomPadding).css("height")).toBe "0px"
    )
    it "should call get on the datasource 1 time ", inject(($rootScope, $compile, myEmptyDatasource) ->
      spy = spyOn(myEmptyDatasource, "get").andCallThrough()
      scroller = angular.element("<div ng-scroll=\"item in myEmptyDatasource\">{{$index}}: {{item}}</div>")
      sandbox.append scroller
      $compile(scroller) $rootScope
      $rootScope.$apply()
      expect(spy.calls.length).toBe 1
      expect(spy.calls[0].args[0]).toBe 1
    )

  
  #                expect(spy.calls[1].args[0]).toBe(-9);
  describe "datasource with only 3 elements", ->
    it "should create 3 divs with data (+ 2 padding divs)", inject(($rootScope, $compile, myOnePageDatasource) ->
      scroller = angular.element("<div ng-scroll=\"item in myOnePageDatasource\">{{$index}}: {{item}}</div>")
      sandbox.append scroller
      $compile(scroller) $rootScope
      $rootScope.$apply()
      expect(sandbox.children().length).toBe 5
      row1 = sandbox.children()[1]
      expect(row1.tagName.toLowerCase()).toBe "div"
      expect(row1.innerHTML).toBe "1: one"
      row2 = sandbox.children()[2]
      expect(row2.tagName.toLowerCase()).toBe "div"
      expect(row2.innerHTML).toBe "2: two"
      row3 = sandbox.children()[3]
      expect(row3.tagName.toLowerCase()).toBe "div"
      expect(row3.innerHTML).toBe "3: three"
    )
    it "should call get on the datasource 3 times ", inject(($rootScope, $compile, myOnePageDatasource) ->
      spy = spyOn(myOnePageDatasource, "get").andCallThrough()
      scroller = angular.element("<div ng-scroll=\"item in myOnePageDatasource\">{{$index}}: {{item}}</div>")
      sandbox.append scroller
      $compile(scroller) $rootScope
      $rootScope.$apply()
      expect(spy.calls.length).toBe 3
      expect(spy.calls[0].args[0]).toBe 1
      expect(spy.calls[1].args[0]).toBe 4
      expect(spy.calls[2].args[0]).toBe -9
    )

