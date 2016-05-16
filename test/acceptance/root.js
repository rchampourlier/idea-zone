casper.test.begin('/', 2, function suite(test) {
  casper.start('http://localhost:4001', function() {
    test.assertTitle('IdeaZone', 'has correct title');
    test.assertUrlMatch('/contents', 'redirects to /contents');
  });
  casper.run(function() {
    test.done();
  });
});
