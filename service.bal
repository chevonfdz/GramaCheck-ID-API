import ballerina/http;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/log;

// Types
type Person record {|
    string firstName;
    string lastName;
    string dob;
    string address;
    string telno;
    string nic;
|};

type isValid record {
    boolean valid;
    string nic;
    string address;
};

// MySQL configuration parameters
configurable string host = ?;
configurable string user = ?;
configurable string password = ?;
configurable string database = ?;

final mysql:Client mysqlClient = check new (host = host, user = user, password = password, database = database);

service / on new http:Listener(9090) {

    isolated resource function post addPerson(@http:Payload Person payload) returns Person|error? {
        sql:ParameterizedQuery insertQuery = `INSERT INTO iddetails VALUES (
                                              ${payload.firstName}, ${payload?.lastName}, ${payload.dob}, ${payload.address}, ${payload.telno},
                                               ${payload.nic})`;
        sql:ExecutionResult _ = check mysqlClient->execute(insertQuery);
        log:printInfo("Successfully posted");
    }

    isolated resource function get checkNIC(string nic) returns isValid|error? {

        Person|error queryRowResponse = mysqlClient->queryRow(`select * from iddetails where nic=${nic.trim()}`);

        if queryRowResponse is error {
            isValid result = { 
                valid: false, nic:nic, address:""
            };
            return result;
        }
        if queryRowResponse is Person {
            isValid result = {
                valid: true, nic:nic, address: queryRowResponse.address
            };
            return result;
        }
    
    }
}
