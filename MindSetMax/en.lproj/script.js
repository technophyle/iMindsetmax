

$(document).ready(function(){

  // Blog feed
  if ( $('#blog-feed') ) {
    $.ajax({
      type: "GET",
      url: "http://www.mindsetmax.com/feed/",
      dataType: "xml",
      success: function(xml) {
        $('#blog-feed').empty();
        $(xml).find('channel').find('item').each(function(){
          var title = $(this).find('title').text();
          var description = $(this).find('description').text();
          var pubDate = $(this).find('pubDate').text();
          var item = $("<div class='blog-item'></div>");
          $('#blog-feed').append(item);
          item.append("<div class='blog-item-title'>" + title + "</div>");
          item.append("<div class='blog-item-date'>" + (new Date(Date.parse(pubDate))).toString() + "</div>");
          item.append("<div class='blog-item-description'>" + description + "</div>");
        });
      }
    });
  }
 
});
