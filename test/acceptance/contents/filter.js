casper.test.begin('/contents', 2, function suite (test) {
  casper.start('http://localhost:4001/contents', function () {
    test.assertExists('#elm-container', 'elm container is displayed')
    this.fill('form', {
      'filter-text': 'efficace'
    })

    casper.options.onResourceReceived = function (resource) {
      console.log(resource)
    };

    casper.waitFor (function check() {
      return this.evaluate(function () {
        return document.querySelectorAll('.content').length === 1
      })
    }, function then () { // step to execute when check() is ok
      test.assert(true, 'matching content only is displayed')
    }, function timeout () { // step to execute if check has failed
      casper.test.fail('text filter failed')
    })
  })

  casper.run (function () {
    test.done()
  })
})
