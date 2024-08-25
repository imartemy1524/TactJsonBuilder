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
            builder = builder.appendObject(
                createJsonObject()
                    .appendString("name",value.name)
                    .appendNumber("age", value.age)
                    .appendCoins("salary", value.salary)
            );
        }
        let json = builder.toString();
        self.reply(json.asComment());
    }
}
