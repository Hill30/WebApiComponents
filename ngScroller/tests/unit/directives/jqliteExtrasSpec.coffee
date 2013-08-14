describe "\njqLite: testing against jQuery\n", ->
  "use strict"
  sandbox = angular.element("<div/>")
  extras = `undefined`
  beforeEach module("ui.scroll.jqlite")
  beforeEach ->
    angular.element(document).find("body").append sandbox = angular.element("<div></div>")
    inject (jqLiteExtras) ->
      extras = ->

      jqLiteExtras.registerFor extras


  afterEach ->
    sandbox.remove()

  describe "height() getter for window\n", ->
    it "should work for window element", ->
      element = angular.element(window)
      expect(extras::height.call(element)).toBe element.height()


  describe "getters height() and outerHeight()\n", ->
    createElement = (element) ->
      result = angular.element(element)
      sandbox.append result
      result
    angular.forEach ["<div>some text</div>", "<div style=\"height:30em\">some text (height in em)</div>", "<div style=\"height:30px\">some text height in px</div>", "<div style=\"border-width: 3px; border-style: solid; border-color: red\">some text w border</div>", "<div style=\"border-width: 3em; border-style: solid; border-color: red\">some text w border</div>", "<div style=\"padding: 3px\">some text w padding</div>", "<div style=\"padding: 3em\">some text w padding</div>", "<div style=\"margin: 3px\">some text w margin</div>", "<div style=\"margin: 3em\">some text w margin</div>"], (element) ->
      it "should be the same as jQuery height() for " + element, ->
        ((element) ->
          expect(extras::height.call(element)).toBe element.height()
        ) createElement(element)

      it "should be the same as jQuery outerHeight() for " + element, ->
        ((element) ->
          expect(extras::outerHeight.call(element)).toBe element.outerHeight()
        ) createElement(element)

      it "should be the same as jQuery outerHeight(true) for " + element, ->
        ((element) ->
          expect(extras::outerHeight.call(element, true)).toBe element.outerHeight(true)
        ) createElement(element)



  describe "height(value) setter\n", ->
    createElement = (element) ->
      result = angular.element(element)
      sandbox.append result
      result
    angular.forEach ["<div>some text</div>", "<div style=\"height:30em\">some text (height in em)</div>", "<div style=\"height:30px\">some text height in px</div>", "<div style=\"border-width: 3px; border-style: solid; border-color: red\">some text w border</div>", "<div style=\"border-width: 3em; border-style: solid; border-color: red\">some text w border</div>", "<div style=\"padding: 3px\">some text w padding</div>", "<div style=\"padding: 3em\">some text w padding</div>", "<div style=\"margin: 3px\">some text w margin</div>", "<div style=\"margin: 3em\">some text w margin</div>"], (element) ->
      validateHeight = (element) ->
        expect(extras::height.call(element)).toBe element.height()
        h = element.height()
        extras::height.call element, h * 2
        expect(extras::height.call(element)).toBe h * 2
      it "height(value) for " + element, ->
        ((element) ->
          expect(extras::height.call(element)).toBe element.height()
          h = element.height()
          extras::height.call element, h * 2
          expect(extras::height.call(element)).toBe h * 2
        ) createElement(element)



  describe "offset() getter\n", ->
    createElement = (element) ->
      result = angular.element(element)
      sandbox.append result
      result
    
    #				'<div style="height:30px">some text height in px</div>',
    #				'<div style="border-width: 3px; border-style: solid; border-color: red">some text w border</div>',
    #				'<div style="border-width: 3em; border-style: solid; border-color: red">some text w border</div>',
    #				'<div style="padding: 3px">some text w padding</div>',
    #				'<div style="padding: 3em">some text w padding</div>',
    #				'<div style="margin: 3px">some text w margin</div>',
    angular.forEach ["<div><div>some text</div></div>", "<div style=\"height:30em\"><div>some text (height in em)</div></div>", "<div style=\"margin: 3em\"><p>some text w margin</p></div>"], (element) ->
      it "should be the same as jQuery offset() for " + element, ->
        ((element) ->
          target = $(element.contents()[0])
          expect(extras::offset.call(target)).toEqual element.offset()
        ) createElement(element)



  describe "scrollTop()\n", ->
    createElement = (element) ->
      result = angular.element(element)
      sandbox.append result
      result
    it "should be the same as jQuery scrollTop() for window", ->
      createElement "<div style=\"height:10000px; width:10000px\"></div>"
      element = $(window)
      expect(extras::scrollTop.call(element)).toBe element.scrollTop()
      element.scrollTop 100
      expect(extras::scrollTop.call(element)).toBe element.scrollTop()
      extras::scrollTop.call element, 200
      expect(extras::scrollTop.call(element)).toBe element.scrollTop()

    it "should be the same as jQuery scrollTop() for window", ->
      element = createElement("<div style=\"height:100px; width:100px; overflow: auto\"><div style=\"height:10000px; width:10000px\"></div></div>")
      expect(extras::scrollTop.call(element)).toBe element.scrollTop()
      element.scrollTop 100
      expect(extras::scrollTop.call(element)).toBe element.scrollTop()
      extras::scrollTop.call element, 200
      expect(extras::scrollTop.call(element)).toBe element.scrollTop()


