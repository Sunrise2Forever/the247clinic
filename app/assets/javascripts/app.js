jQuery(document).on('page:change', function() {
  App.init();
  jQuery('.tp-banner').revolution({
    delay:9000,
    startwidth:1170,
    startheight:500,
    hideThumbs:10,
    navigationStyle:"preview4"
  });
});
