import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

http:Client github = check new ("https://ccc89048-bed6-43e6-9dd7-51f1e03d45c4-dev.e1-us-east-azure.choreoapis.dev/hmjo/e2metrics/1.0.0");

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new (8090);
listener asgardeo:Listener webhookListener = new (config, httpListener);
mysql:Options mysqlOptions = {
    ssl: {
        mode: mysql:SSL_PREFERRED
    },
    connectTimeout: 100
};
mysql:Client dbClient = check new ("e2metrics.cu0vbdes0onb.eu-north-1.rds.amazonaws.com", "admin", "yYaN!3nGec%SHt", "E2Metrices", 3306);

type EventData record {
    string 'userName?;
    string 'userId?;
};

type Event record {
    EventData 'eventData?;
};

service asgardeo:RegistrationService on webhookListener {

    remote function onAddUser(asgardeo:AddUserEvent event) returns error? {
        string UserID = <string>event?.eventData?.userId;
        string UserName = <string>event?.eventData?.userName;
        do {
            _ = check dbClient->execute(`
	            INSERT INTO Users (UserID,UserName)
	            VALUES (${UserID},${UserName});`);
        } on fail var e {
            log:printInfo(e.toString());
        }

        string url = "/user/changeUserGroup?userId=" + UserID + "&groupName=Free";

        json _ = check github->put(url, {});

    }

    remote function onConfirmSelfSignup(asgardeo:GenericEvent event) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onAcceptUserInvite(asgardeo:GenericEvent event) returns error? {

        log:printInfo(event.toJsonString());
    }
}

service /ignore on httpListener {
}
