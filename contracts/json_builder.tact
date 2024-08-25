import "@stdlib/deploy";
import "./json.tact";
struct Employee{
    name: String;
    age: Int as uint8;
    salary: Int as coins;
}
message MapMessage{
    data: map<Int, Employee>;
}
contract JsonBuilder with Deployable {

    receive(m: MapMessage){
        let builder = createJsonArray();
        foreach(key, value in m.data){
            builder = builder.appendToArray(
                createJsonObject()
                    .appendToObject("name", creteJsonString(value.name))
                    .appendToObject("age", createJsonNumber(value.age))
                    .appendToObject("salary", createJsonCoins(value.salary))
            );
        }
        let json = builder.toString();
        self.reply(json);
    }
}
