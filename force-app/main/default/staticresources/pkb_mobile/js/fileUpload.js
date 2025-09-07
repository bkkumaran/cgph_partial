define([
  'jquery',
  'underscore',
  'backbone'
], function($,_, Backbone){

    var fUpload = function(){};

    _.extend(fUpload.prototype, {

    /** FILE UPLOAD HANDLING
      adaptation from : https://github.com/TehNrd/Multi-File-Uploader-Force.com
    **/
    parentId : null,
    byteChunkArray: null, 
    files: null, 
    currentFile: null, 
    $upload: null, 
    CHUNK_SIZE : 180000, //Must be evenly divisible by 3, if not, data corruption will occur 
   
  //Executes when start Upload button is selected
  prepareFileUploads : function (fileList,parentId, parentRef, contactData){
    //Get the file(s) from the input field
    this.files = fileList;
    this.parentId = parentId;
    this.parentRef = parentRef;
    this.contactData = contactData;
    //Only proceed if there are files selected
    if(this.files.length == 0){
      alert(pkb2_LANG.get('selectFile'));
      return;
    }
    
    //Build out the upload divs for each file selected
    var uploadMarkup = '';
    //remove all previous thumbnails
    $('#picThumbnail span').remove();
    var totalSize = 0;
    for(i = 0; i < this.files.length; i++){
      //Determine total file display size
      totalSize = totalSize + this.files[i].size;
    }    
    //add modal with upload in progress
    parentRef.trigger('displayUploadInProgress',this);
    //Once elements have been added to the page representing the uploads, start the actual upload process
    this.checkForUploads();
  },
  
  checkForUploads : function (){
    //Get div of the first matching upload element that is 'pending', if none, all uploads are complete

    $upload = $(".upload[data-status='pending']:first");
    
    if($upload.length > 0){
      //Based on index of the div, get correct file from files array
      this.currentFile = this.files[$upload.attr('data-index')];//0];
      /*Build the byteChunkArray array for the current file we are processing. This array is formatted as:
      ['0-179999','180000-359999',etc] and represents the chunks of bytes that will be uploaded individually.*/
      this.byteChunkArray = new Array();  
      //First check to see if file size is less than the chunk size, if so first and only chunk is entire size of file
      if(this.currentFile.size <= this.CHUNK_SIZE){
        this.byteChunkArray[0] = '0-' + (this.currentFile.size - 1);
      }else{
        //Determine how many whole byte chunks make up the file,
        var numOfFullChunks = Math.floor(this.currentFile.size / this.CHUNK_SIZE); //i.e. 1.2MB file would be 1000000 / CHUNK_SIZE
        var remainderBytes = this.currentFile.size % this.CHUNK_SIZE; // would determine remainder of 1200000 bytes that is not a full chunk
        var startByte = 0;
        var endByte = this.CHUNK_SIZE - 1;        
        //Loop through the number of full chunks and build the this.byteChunkArray array
        for(i = 0; i < numOfFullChunks; i++){
          this.byteChunkArray[i] = startByte+'-'+endByte;
          //Set new start and stop bytes for next iteration of loop
          startByte = endByte + 1;
          endByte += this.CHUNK_SIZE;
        }        
        //Add the last chunk of remaining bytes to the this.byteChunkArray
        startByte = this.currentFile.size - remainderBytes;
        endByte = this.currentFile.size;
        this.byteChunkArray.push(startByte+'-'+endByte);
      }      
      //Start processing the this.byteChunkArray for the current file, parameter is '' because this is the first chunk being uploaded and there is no attachment Id
      this.processByteChunkArray('');
    }else{
      $("input[type='file']").val('');
      this.parentRef.trigger('submitSuccess',this.contactData);

    }
  },
  
  //Uploads a chunk of bytes, if attachmentId is passed in it will attach the bytes to an existing attachment record
  processByteChunkArray : function (attachmentId){
  //Proceed if there are still values in the byteChunkArray, if none, all piece of the file have been uploaded
    if(this.byteChunkArray.length > 0){
      //Determine the byte range that needs to uploaded, if byteChunkArray is like... ['0-179999','180000-359999']
      var indexes = this.byteChunkArray[0].split('-'); //... get the first index range '0-179999' -> ['0','179999']
      var startByte = parseInt(indexes[0]); //0
      var stopByte = parseInt(indexes[1]); //179999
      //Slice the part of the file we want to upload, this.currentFile variable is set in checkForUploads() method that is called before this method
      this.currentFile.slice = this.currentFile.webkitSlice || this.currentFile.mozSlice || this.currentFile.slice

      var blobChunk = this.currentFile.slice(startByte , stopByte + 1);
      //Create a new reader object, part of HTML5 File API
      var reader = new FileReader();
      //Read the blobChunk as a binary string, reader.onloadend function below is automatically called after this line
      reader.readAsBinaryString(blobChunk);
      var that = this;
      //Create a reader.onload function, this will execute immediately after reader.readAsBinaryString() function above;
      reader.onloadend = function(evt){ 
        if(evt.target.readyState == FileReader.DONE){ //Make sure read was successful, DONE == 2
          //Base 64 encode the data for transmission to the server with JS remoting, window.btoa currently on support by some browsers
          var base64value = window.btoa(evt.target.result);
          //Use js remoting to send the base64 encoded chunk for uploading
          pkb_mobile_proxy.postBlobContent(that.parentId,attachmentId,that.currentFile.name,that.currentFile.type,base64value,function(result,event){
            //Proceed if there were no errors with the remoting call
            if(event.status == true){              //Remove the index information from the byteChunkArray array for the piece just uploaded.
              that.byteChunkArray.shift(); //removes 0 index
              //Set the attachmentId of the file we are now processing
              attachmentId = result;
              //Call process this.byteChunkArray to upload the next piece of the file
              that.processByteChunkArray(attachmentId);
            }else{
              //If script is here something broke on the JavasSript remoting call
             alert(pkb2_LANG.get('error_on_file_upload'));
              //Check and continue the next file to upload
              that.checkForUploads();
            }
          }); 
        }else{
          //Error handling for bad read
          alert(pkb2_LANG.get('can_not_read_file'));
        }
      };
    }else{  
      //This file has completed, all byte chunks have been uploaded, set status on the div to complete
      $upload.attr('data-status','complete');
      //Call the checkForUploads to find the next upload div that has data-status="incomplete" and start the upload process. 
      this.checkForUploads();
    }
  }
});
return fUpload;
});