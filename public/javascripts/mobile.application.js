$(function() {
  $("#username, #password").keyup(function() {
    localStorage.setItem($(this).attr("id"), $(this).val());
  });
  
  $("#username").val(localStorage.getItem("username"));
  $("#password").val(localStorage.getItem("password"));
  
  var last = null;
  $("input").keyup(function() {
    clearTimeout(last);
    last = setTimeout(function() {
      $.post("/validate", {
        username: localStorage.getItem("username"),
        password: localStorage.getItem("password")
      });
    }, 500);
  });
});

$(function() {
  var $button = $("#button");
  var $buttonText = $button.find("span");
  var buttonName = $buttonText.text();
  
  client = new Faye.Client("http://" + document.domain + ":9999/faye");
  client.subscribe("/reserve/" + $.cookie("uuid"), function(message) {
    message = JSON.parse(message);
    if(message.job == "validate") {
      if(message.valid) {
        $.mobile.changePage("#now", {changeHash: false});
        localStorage.setItem("valid", message.valid.toString());
      }
    } else if(message.notification == "no_room"){
      $buttonText.text("Noting found");
    } if(message.notification == "valid"){
      localStorage.setItem("reservation", JSON.stringify({
        day: new Date().getTime(),
        room: message.room
      }));
      $button.replaceWith('<div id="room">' + message.room + "</div>");
    }    
  });
  
  $.mobile.pageContainer = $("#page");
  if(localStorage.getItem("valid") == "true"){
    setTimeout(function() {
      var reservation = JSON.parse(localStorage.getItem("reservation") || "{}");
      if(reservation.room && reservation.day){
        if(new Date().getDay() == new Date(reservation.day).getDay()){
           $.mobile.pageContainer.find("[data-role='content']").html('<div id="room">' + reservation.room + "</div>"); 
           return;
        }
      }
      $.mobile.changePage("#now", {changeHash: false});
    }, 10);
  }
  
  $button.click(function() {
    $buttonText.text("Loading...");
    $.post("/now", {
      username: localStorage.getItem("username"),
      password: localStorage.getItem("password")
    });
  });
})