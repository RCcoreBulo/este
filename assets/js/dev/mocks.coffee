global.assert = require('/usr/local/lib/node_modules/chai').assert

###
	DOM stub (almost). Would be better to not have a mock, but Google Closure
	depends on DOM. For example, dom_.removeNode needs parentNode.
	Instead of complicated, always reimplemented stubs, we implemented several DOM methods.
	It's all about moving complexity from tests to shared (this file) DOM implementation.
	http://martinfowler.com/articles/mocksArentStubs.html
	todo: create a createDocument method
###
global.document =
	addEventListener: ->
	# todo: use constructor
	createElement: (tag) ->
		offsetWidth: 0
		offsetHeight: 0
		tagName: tag.toUpperCase()
		nodeType: 1
		className: ''
		ownerDocument: global.document
		style:
			opacity: 1
		__style: {}
		childNodes: []
		appendChild: (node) ->
			@childNodes.push node
			node.parentNode = @
			node
		removeChild: (node) ->
			node.parentNode = null
			node
		insertBefore: (newElement, referenceElement) ->
			idx = @childNodes.indexOf referenceElement
			@childNodes.splice idx, 0, newElement
			newElement.parentNode = @
		addEventListener: ->
	defaultView:
		getComputedStyle: (element) ->
			# this is how we can foist computed styles for every element
			element.__style = element.__style || {}
			style =
				paddingLeft: 0
				paddingRight: 0
				paddingTop: 0
				paddingBottom: 0
				marginLeft: 0
				marginRight: 0
				marginTop: 0
				marginBottom: 0
				borderLeftWidth: 0
				borderRightWidth: 0
				borderTopWidth: 0
				borderBottomWidth: 0
				getPropertyValue: -> 0
			style[k] = v for k, v of element.__style
			style

html = global.document.createElement 'html'
global.document.body = html.appendChild global.document.createElement 'body'