
const JSON_TYPE_OBJECT: Int = 0;
const JSON_TYPE_ARRAY: Int = 1;
const JSON_TYPE_STRING: Int = 2;
const JSON_TYPE_NUMBER: Int = 3;
const JSON_TYPE_COINS: Int = 4;

struct ObjectElement{
    key: String;
    value: JsonElement;
}

struct JsonBuilderObject{
    //slice - String
    content: map<Int as uint8, ObjectElement>;
    elementsCount: Int as uint64 = 0;
}
struct JsonBuilderArray{
    //slice - String
    content: map<Int as uint8, JsonElement>;
    elementsCount: Int as uint64 = 0;
}

struct JsonElement{
    type: Int as uint8;
    value: Slice;
}


fun createJsonArray(): JsonElement{
    //TODO: toCell costs a lot of gas
    return JsonElement{type: JSON_TYPE_ARRAY, value: JsonBuilderArray{content: emptyMap()}.toCell().asSlice()};
}
fun createJsonObject(): JsonElement{
    return JsonElement{type: JSON_TYPE_OBJECT, value: JsonBuilderObject{content: emptyMap()}.toCell().asSlice()};
}
fun creteJsonString(value: String): JsonElement{
    return JsonElement{type: JSON_TYPE_STRING, value: value.asSlice()};
}
fun createJsonNumber(value: Int): JsonElement{
    return JsonElement{type: JSON_TYPE_NUMBER, value: beginCell().storeInt(value, 64).endCell().asSlice()};
}
fun createJsonCoins(value: Int): JsonElement{
    return JsonElement{type: JSON_TYPE_COINS, value: beginCell().storeCoins(value).endCell().asSlice()};
}

extends fun toString(self: JsonElement): String {
    if(self.type == JSON_TYPE_STRING){
        //TODO: quote escaping
        return beginString().concat("\"").concat(self.value.asString()).concat("\"").toString();
    }
    else if(self.type == JSON_TYPE_COINS){
        let coins = self.value.loadCoins();
        return coins.toCoinsString();
    }
    else if(self.type == JSON_TYPE_NUMBER){
        return self.value.loadInt(64).toString();
    }
    else if(self.type == JSON_TYPE_OBJECT){
        let builder: StringBuilder = beginString();
        builder.append("{");
        let object: JsonBuilderObject = JsonBuilderObject.fromSlice(self.value);
        foreach(key, value in object.content){
            builder.append("\"");
            builder.append(value.key);
            builder.append("\":");
            builder.append((value.value).toString());
            if(key < object.elementsCount - 1){
                builder.append(",");
            }
        }
        builder.append("}");
        return builder.toString();
    }
    else if(self.type == JSON_TYPE_ARRAY){
        let builder: StringBuilder = beginString();
        builder.append("[");
        let array: JsonBuilderArray = JsonBuilderArray.fromSlice(self.value);
        foreach(key, value in array.content){
            builder.append(toString(value));
            if(key < array.elementsCount - 1){
                builder.append(",");
            }
        }
        builder.append("]");
        return builder.toString();
    }
}
extends fun appendToArray(self: JsonElement, value: JsonElement): JsonElement {
    require(value.type == JSON_TYPE_ARRAY, "Invalid JSON object type");
    let element: JsonBuilderArray = JsonBuilderArray.fromSlice(value.value);
    element.content.set(element.elementsCount, value);
    element.elementsCount += 1;
    return JsonElement{type: JSON_TYPE_ARRAY, value: element.toCell().asSlice()};
}
extends fun appendToObject(self: JsonElement, key: String, value: JsonElement): JsonElement {
    require(value.type == JSON_TYPE_OBJECT, "Invalid JSON object type");
    let element: JsonBuilderObject = JsonBuilderObject.fromSlice(value.value);
    element.content.set(element.elementsCount, ObjectElement{key, value});
    element.elementsCount += 1;
    return JsonElement{type: JSON_TYPE_OBJECT, value: element.toCell().asSlice()};
}