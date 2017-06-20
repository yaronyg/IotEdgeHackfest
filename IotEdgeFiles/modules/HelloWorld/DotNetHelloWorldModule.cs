// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Devices.Gateway;


namespace HelloWorld
{
    public class DotNetHelloWorld : IGatewayModuleStart
    {
        private string configuration;
        public void Create(Broker broker, byte[] configuration)
        {
            this.configuration = System.Text.Encoding.UTF8.GetString(configuration);
        }

        public void Start() 
        {
            Console.WriteLine("We are saying HELLO WORLD!!!!!");
        }

        public void Destroy()
        {
        }

        public void Receive(Message received_message)
        {
        }
    }
}
