Create a Developer APIM service and enable managed identity for the APIM Service as shown below

![alt text](apim.png)


Write the APIM policy as mentioned down below
```
<policies>
    <inbound>
        <authentication-managed-identity resource="https://servicebus.azure.net" output-token-variable-name="msi-access-token" ignore-error="false" />
        <set-header name="Authorization" exists-action="override">
            <value>@((string)context.Variables["msi-access-token"])</value>
        </set-header>
        <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
        </set-header>
        <set-backend-service base-url="https://dev-svcbus-001.servicebus.windows.net" />
        <rewrite-uri template="topic1/messages" />
        <base />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
```
create a service bus

Create a topic named topic1 and subscription named subscription 1 as mentioned down below

![alt text](servicebus.png)![alt text](topic.png)![alt text](image.png)


Finally create a function app
```
import azure.functions as func
import logging

app = func.FunctionApp()

@app.service_bus_topic_trigger(arg_name="azservicebus", subscription_name="sub1", topic_name="topic1",
                               connection="Endpoint=sb://dev-svcbus-001.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=6gLOD01sr+PNyu7A8la3J5VAXIb3gCq0A+ASbLDkl5o=") 
def servicebus_topic_trigger1(azservicebus: func.ServiceBusMessage):
    logging.info('Python ServiceBus Topic trigger processed a message: %s',
                azservicebus.get_body().decode('utf-8'))
```

```
So basically what is happening here

we will invoke a API call 

The API call is then Recived by Service bus topic

Azure function then recives the message as a subscriber and gets triggered

This is called asynchornous communication where its one way communication
```
