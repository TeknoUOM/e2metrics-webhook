import ballerinax/trigger.asgardeo;
import ballerina/http;
import ballerina/io;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new (8090);
listener asgardeo:Listener webhookListener = new (config, httpListener);

service asgardeo:RegistrationService on webhookListener {

    remote function onAddUser(asgardeo:AddUserEvent event) returns error? {
        io:print(event);
    }

    remote function onAcceptUserInvite(asgardeo:GenericEvent event) returns error? {
        io:print(event);
    }

    remote function onConfirmSelfSignup(asgardeo:GenericEvent event) returns error? {
        io:print(event);
    }
}

service /ignore on httpListener {
}
