public class getAttach {

 public String pId {get; set;}
 public String pName {get; set;}
 
 public getAttach(){
  pId = apexpages.currentpage().getparameters().get('p');
  pName = apexpages.currentpage().getparameters().get('n');
 }
 
 public List<Attachment> getAtt() {
         return [SELECT Name, Id
                FROM
                Attachment
                WHERE
                ParentId = :pId];
        }
        
}