###! jquery-grishania 2.3.42 http://github.com/Se7enSky/jquery-grishania###
###
@name jquery-grishania
@description Meet Grishania – just another scroll engine.
@version 2.3.42
@author Se7enSky studio <info@se7ensky.com>
###

plugin = ($) ->
	"use strict"

	class Grishania
		defaults:
			slideAttrName: 'data-slide'
			addSlideStateToBody: on

		constructor: (@el, options) ->
			@$el = $ @el
			@options = $.extend {}, @defaults, options
			@slides = {}
			@currentScroll = $(window).scrollTop()
			@currentWindowHeight = $(window).height()

			@readSlides()
			@bindEvents()
			@refreshSlideStates()

			window.dumpGrishania = =>
				onSlides = []
				activeSlides = []
				for slideName, slide of @slides
					onSlides.push slide.name if slide.on
					activeSlides.push slide.name if slide.active
				console.log "on", onSlides
				console.log "active", activeSlides
				console.log "currentScroll", @currentScroll

		readElHeight: (el) ->
			parseFloat $(el).css("height").replace("px", "")

		readSlides: ->
			if @slides.length > 0 and @options.addSlideStateToBody
				$('body').removeClass ("slide-#{slide.name}-on slide-#{slide.name}-off slide-#{slide.name}-active" for slideName of @slides).join " "
			$("[#{@options.slideAttrName}]").each (i, slideEl) =>
				slideName = $(slideEl).attr @options.slideAttrName
				slideStart = $(slideEl).offset().top
				slideEnd = slideStart + @readElHeight slideEl
				slide = @slides[slideName] or @slides[slideName] =
					name: slideName
					el: slideEl
					on: no
					active: no
				slide.start = slideStart
				slide.end = slideEnd

		bindEvents: ->
			$(window).on
				scroll: =>
					@currentScroll = $(window).scrollTop()
					@refreshSlideStates()
				"resize webFontsLoaded": =>
					@currentWindowHeight = $(window).height()
					@readSlides()
					@refreshSlideStates()
			$(document).on
				requestReGrishania: =>
					for slideName, slide of @slides
						$(slide.el).trigger (if slide.on then "onSlide" else "offSlide"), slide
						$(slide.el).trigger (if slide.active then "activatedSlide" else "deactivatedSlide"), slide

			if @options.addSlideStateToBody
				$body = $('body')
				c = (add, remove) ->
					$body.removeClass remove if remove
					$body.addClass add if add
				$(document).on
					'activatedSlide': (e, slide) -> c "slide-#{slide.name}-active"
					'deactivatedSlide': (e, slide) -> c no, "slide-#{slide.name}-active"
					'onSlide': (e, slide) -> c "slide-#{slide.name}-on", "slide-#{slide.name}-off"
					'offSlide': (e, slide) -> c "slide-#{slide.name}-off", "slide-#{slide.name}-on"

		refreshSlideStates: ->
			for slideName, slide of @slides
				if @currentScroll + @currentWindowHeight > slide.start and @currentScroll < slide.end
					@on slide
				else
					@off slide

				if slide.start <= @currentScroll + @currentWindowHeight / 2 < slide.end
					@activate slide
				else
					@deactivate slide

		on: (slide) ->
			return if slide.on
			slide.on = yes
			$(slide.el).trigger 'onSlide', slide
		off: (slide) ->
			return if not slide.on
			slide.on = no
			$(slide.el).trigger 'offSlide', slide
		activate: (slide) ->
			return if slide.active
			slide.active = yes
			$(slide.el).trigger 'activatedSlide', slide
		deactivate: (slide) ->
			return if not slide.active
			slide.active = no
			$(slide.el).trigger 'deactivatedSlide', slide

	$.fn.grishania = (options) ->
		$this = $(@)
		grishania = $this.data 'grishania'
		if not grishania
			$this.data 'grishania', (grishania = new Grishania @, options)

		@ # chaining

# UMD 
if typeof define is 'function' and define.amd then define(['jquery'], plugin) else plugin(jQuery)
