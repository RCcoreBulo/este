suite 'este.mvc.Model', ->

  Person = (attrs) ->
    goog.base @, attrs
    return

  goog.inherits Person, este.mvc.Model

  Person::schema = 
    'firstName':
      'set': (name) -> goog.string.trim name
    'lastName':
      'validators':
        'required': (value) -> value && goog.string.trim(value).length
    'name':
      'meta': (self) -> self.get('firstName') + ' ' + self.get('lastName')
    'age':
      'get': (age) -> Number age

  attrs = null
  model = null

  setup ->
    attrs =
      'firstName': 'Joe'
      'lastName': 'Satriani'
      'age': 55
    model = new Person attrs

  suite 'constructor', ->
    test 'should assign id', ->
      model = new Person
      assert.isString model.get 'id'

    test 'should not override id', ->
      model = new Person id: 'foo'
      assert.equal model.get('id'), 'foo'

    test 'should create attributes', ->
      model = new Person
      assert.isUndefined model.get 'firstName'

    test 'should return passed attributes', ->
      assert.strictEqual model.get('firstName'), 'Joe'
      assert.strictEqual model.get('lastName'), 'Satriani'
      assert.strictEqual model.get('age'), 55

  suite 'set and get', ->
    test 'should set attribute', ->
      model.set 'age', 35
      assert.strictEqual model.get('age'), 35

    test 'should set attributes', ->
      model.set 'age': 35, 'firstName': 'Pepa'
      assert.strictEqual model.get('age'), 35
      assert.strictEqual model.get('firstName'), 'Pepa'

  suite 'get', ->
    test 'should accept array and return object', ->
      assert.deepEqual model.get(['age', 'firstName']),
        'age': 55
        'firstName': 'Joe'

  suite 'toJson', ->
    test 'with true and without attrs should return just id', ->
      model = new Person
      json = model.toJson true
      attrs = 'id': json.id
      assert.deepEqual json, attrs

    test 'with true and without attrs should return just id', ->
      model = new Person
      json = model.toJson()
      attrs =
        'id': json.id
        'name': 'undefined undefined'
      assert.deepEqual json, attrs
    
    test 'should return setted attributes json and metas', ->
      json = model.toJson()
      attrs =
        'firstName': 'Joe'
        'lastName': 'Satriani'
        'name': 'Joe Satriani'
        'age': 55
        'id': json.id
      assert.deepEqual json, attrs

  suite 'has', ->
    test 'should work', ->
      assert.isTrue model.has 'age'
      assert.isFalse model.has 'fooBlaBlaFoo'
    
    test 'should work even for keys which are defined on Object.prototype.', ->
      assert.isFalse model.has 'toString'
      assert.isFalse model.has 'constructor'
      assert.isFalse model.has '__proto__'
      # etc. from Object.prototype

  suite 'remove', ->
    test 'should work', ->
      assert.isTrue model.has 'age'
      model.remove 'age'
      assert.isFalse model.has 'age'

  suite 'schema', ->
    
    suite 'set', ->
      test 'should work as formater before set', ->
        model.set 'firstName', '  whitespaces '
        assert.equal model.get('firstName'), 'whitespaces'

    suite 'get', ->
      test 'should work as formater after get', ->
        model.set 'age', '1d23'
        assert.isNumber model.get 'age'

  suite 'change event', ->
    test 'should be dispached if value change', (done) ->
      goog.events.listenOnce model, 'change', (e) ->
        assert.deepEqual e.attrs,
          age: 'foo'
        done()
      model.set 'age', 'foo'

    test 'should not be dispached if value hasnt changed', ->
      called = false
      goog.events.listenOnce model, 'change', (e) ->
        called = true
      model.set 'age', 55
      assert.isFalse called

    test 'should be dispached if value is removed', ->
      called = false
      goog.events.listenOnce model, 'change', (e) ->
        called = true
      model.remove 'age'
      assert.isTrue called

  suite 'meta', ->
    test 'should defined meta attribute', ->
      assert.equal model.get('name'), 'Joe Satriani'

  suite 'validation', ->
    test 'should fulfil errors and prevent attr change', ->
      model.set 'lastName', ''
      assert.deepEqual model.errors,
        'lastName':
          'required': true
      assert.equal model.get('lastName'), 'Satriani'

  suite 'bubbling events', ->
    test 'from inner model should work', ->
      called = 0
      innerModel = new Person
      model.set 'inner', innerModel
      goog.events.listen model, 'change', (e) ->
        called++
      innerModel.set 'name', 'foo'
      model.remove 'inner', innerModel
      innerModel.set 'name', 'foo'
      assert.equal called, 2

  suite 'errors', ->
    test 'should works across sets', ->
      model.set 'lastName', ''
      assert.deepEqual model.errors, {lastName: {required: true}}
      assert.equal model.get('lastName'), 'Satriani'

  suite 'isValid', ->
    test 'should use scheme validators in set method', ->
      assert.isTrue model.isValid(), 'model is valid'
      assert.isFalse model.set 'lastName', ''
      assert.equal model.get('lastName'), 'Satriani'
      assert.isTrue model.isValid(), 'set will not set invalid state'

    test 'should use scheme validators in constructor too', ->
      model = new Person
      assert.isFalse model.isValid()
      assert.isTrue model.set 'lastName', 'fok'
      assert.isTrue model.isValid()

  suite 'set object', ->
    test 'should set valid keys despite there is one invalid', ->
      assert.equal model.get('firstName'), 'Joe'
      model.set
        firstName: 'Pepa'
        lastName: ''
      assert.equal model.get('firstName'), 'Pepa'

  #suite ''
  # nemeli by se prepisovat errory?
  # mam errror s name.. 
  # pokud nastavuju neco jinyho.. musi zustat
  # pokud nastavuju name.. musi se prepsat.. (odebrat)
  # pak mi pojede editview errors proti setterum v construktoru atd.
  # nebo definovat, ze errors se vztahuji k poslednimu set
  # next issue: selze li jeden set, nenastavi se zadnej..






