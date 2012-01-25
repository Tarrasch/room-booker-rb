$(function() {
  $("#now").click(function() {
    var $self = $(this), name;
    name = $self.text();
    $self.text("Hold on!");
    $.post("/now", {
      username: localStorage.getItem("username"),
      password: localStorage.getItem("password")
    });
    
    setTimeout(function() {
      $self.text(name);
    }, 4000);
    
    return false;
  });  
});
