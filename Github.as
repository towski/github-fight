package
{
  import flash.display.Sprite;
  import flash.display.Bitmap;
  import mx.controls.TextInput;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import flash.text.StyleSheet;
  import flash.text.TextFieldAutoSize;
  import flash.events.*;
  import flash.utils.*;
  import flash.net.URLLoader; 
  import flash.system.Security; 
  import flash.net.URLRequest;
  import flash.display.Loader
  
  [SWF(backgroundColor="#ffffff", frameRate="24", width="800", height="400")]
  public class Github extends Sprite
  {  
    [Embed(source="FFFHARMO.TTF", fontFamily="Harmony")]
    private var harmony:String;

    private var harmony_format:TextFormat;
    private var category:TextField; 
    
    private var random:int;
    private var array:Array;
    private var users:Object;
    private var sprites:Object;
    
    private var imageLoader:Loader;
    
    public function Github(): void{
      array = new Array();
      harmony_format = new TextFormat();
      harmony_format.font = "Harmony";
      harmony_format.size = 20;
      category = new TextField();
      category.autoSize = TextFieldAutoSize.LEFT;
      category.defaultTextFormat = harmony_format;
      category.x = 20;
      category.y = 20;
      category.multiline = true
      category.textColor = 0xffffff;
      category.embedFonts = true
      category.alpha = 2.0
      category.width = 200;
      category.height = 150;
      addChild(category);
      users = new Object();
      sprites = new Object();
      //loadImage("https://secure.gravatar.com/avatar/3debd80702f91991b52cb37fe78a1465")
      addEventListener(Event.ENTER_FRAME, moveUsers)
      loadData()
      setInterval(loadData, 20000)
    }
    
    private function moveUsers(e:Event){
      var neighbor:Sprite;
      var neighborLogin:String;
      var neighborData:Object;
      var userData:Object;
      var killedUsers = new Array()
      var sprite:Sprite;
      for (var user in users){
        if(users[user] != undefined){
          neighborLogin = findNearestNeighbor(user)
          if(neighborLogin != null){
            neighbor = sprites[neighborLogin]
            neighborData = users[neighborLogin]
            userData = users[user]
            sprite = sprites[user]
            
            if(neighbor.y < sprites[user].y){
              sprites[user].y -= 1
            } else if (neighbor.y > sprites[user].y){
              sprites[user].y += 1
            }
            
            if(neighbor.x < sprites[user].x){
              sprites[user].x -= 1
            } else if (neighbor.x > sprites[user].x){
              sprites[user].x += 1
            }
            
            if(neighbor.y == sprite.y && neighbor.x == sprite.x){
              if(int(userData.followers) > int(neighborData.followers)){
                trace(user + " killed " + neighborLogin)
                killedUsers.push(neighborLogin)
              }
            }
          }
        }
      }
      
      for(var i:int = 0; i < killedUsers.length; i++){
        removeChild(sprites[killedUsers[i]])
        users.setPropertyIsEnumerable(killedUsers[i], false)
        sprites.setPropertyIsEnumerable(killedUsers[i], false)
        //users[killedUsers[i]] = undefined
        //sprites[killedUsers[i]] = undefined
      }
    }
    
    function loadImage(url:String):void {
      // Set properties on my Loader object
      imageLoader = new Loader();
      imageLoader.load(new URLRequest(url));
      //imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, imageLoading);
      //imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
    }
    
    private function findNearestNeighbor(user:String):String{
      var shortestDistance:Number = 10000.0;
      var distance:Number;
      var nearestNeighbor:String;
      for (var login in users){
        if(user != login){
          distance = distanceBetween(sprites[login], sprites[user])
          if(distance < shortestDistance){
            shortestDistance = distance
            nearestNeighbor = login;
          }
        }
      }
      return nearestNeighbor;
    }
    
    private function distanceBetween(first:Sprite, second:Sprite):Number{
      return Math.sqrt((Math.pow(first.y - second.y, 2) + Math.pow(first.x - second.x, 2)))
    }
    
    private function loadData():void {
      var request:URLRequest = 
         new URLRequest( "http://jackflash.heroku.com/?resource=https://api.github.com/events&callback=hey" );
      var loader:URLLoader = new URLLoader();
      
      loader.addEventListener(Event.COMPLETE, completeHandler);
      loader.load( request );
    }
     
    private function completeHandler(event:Event):void { 
      var data:Object = new JSONDecoder( event.target.data, false ).getValue()
      var login:String;
      for(var i:int = 0; i < data.length; i++){
        login = data[i].actor.login
        if(users[login] == undefined){
           loadUser(login)
        } else {
          trace('didnt load user ' + login);
        }
      }
    }
    
    private function loadUser(login:String):void {
      var request:URLRequest = 
         new URLRequest( "http://jackflash.heroku.com/?resource=https://api.github.com/users/"+login+"&callback=hey" );
      var loader:URLLoader = new URLLoader();
      
      loader.addEventListener(Event.COMPLETE, userHandler);
      loader.load( request );
    }
    
    private function userHandler(event:Event):void {
      var user:Object = new JSONDecoder( event.target.data, false ).getValue()
      users[user.login] = user;
      var sprite:Sprite = new Sprite()
      sprite.graphics.beginFill(0x00ff00);
      sprite.graphics.drawRect(0, 0, 25, 50);
      sprite.graphics.endFill();
      var random:int = Math.floor(Math.random() * stage.stageWidth);
      sprite.x = random;
      random = Math.floor(Math.random() * stage.stageHeight);
      sprite.y = random;
      addChild(sprite)
      sprites[user.login] = sprite
    }
  }
}
      
