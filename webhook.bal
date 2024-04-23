import ballerina/http;
import ballerina/log;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/trigger.asgardeo;

configurable asgardeo:ListenerConfig config = ?;
configurable string hostname = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string port = ?;
configurable string e2metricsAPIBaseURL = ?;

http:Client github = check new (e2metricsAPIBaseURL);

listener http:Listener httpListener = new (8090);
listener asgardeo:Listener webhookListener = new (config, httpListener);
mysql:Options mysqlOptions = {
    ssl: {
        mode: mysql:SSL_PREFERRED
    },
    connectTimeout: 100
};
mysql:Client dbClient = check new (hostname, username, password, database, port);

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

        do {
            _ = check dbClient->execute(`
	            INSERT INTO AlertLimits (UserID)
	            VALUES (${UserID});`);
        } on fail var e {
            log:printInfo(e.toString());
        }

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
