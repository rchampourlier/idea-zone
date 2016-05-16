casper.test.begin('/contents', 2, function suite(test) {

  casper.start('http://localhost:4001/contents', function() {
    test.assertExists('#elm-container', 'elm container is displayed');
  });

  casper.then(function() {
    casper.waitForSelector('.content', function() {
      test.assertEval(function() {
        return document.querySelectorAll('.content').length == 3;
        // return __utils__.findAll(".content").length == 3;
      }, "3 contents are displayed");
    });
  });

  casper.run(function() {
    test.done();
  });
});
