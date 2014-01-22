Feature: Convert AST

  Background: 
    Given a file named "legacy_ast.json" with:
    """
    {
      "location": "http://www.google.com/",
      "name": "Sample API v2",
      "description": "Welcome to our sample API documentation. All comments can be written in (support [Markdown](http://daringfireball.net/projects/markdown/syntax) syntax)",
      "sections": [
        {
          "name": "Shopping Cart Resources",
          "description": "The following is a section of resources related to the shopping cart",
          "resources": [
            {
              "description": "List products added into your shopping-cart. (comment block again in Markdown)",
              "method": "GET",
              "url": "/shopping-cart",
              "request": {
                "headers": {},
                "body": null
              },
              "responses": [
                {
                  "status": 200,
                  "headers": {
                    "Content-Type": "application/json"
                  },
                  "body": "{\n    \"items\": [\n        {\n            \"url\": \"/shopping-cart/1\",\n            \"product\": \"2ZY48XPZ\",\n            \"quantity\": 1,\n            \"name\": \"New socks\",\n            \"price\": 1.25\n        }\n    ]\n}"
                }
              ]
            },
            {
              "description": "Save new products in your shopping cart",
              "method": "POST",
              "url": "/shopping-cart",
              "request": {
                "headers": {
                  "Content-Type": "application/json"
                },
                "body": "{\n    \"product\": \"1AB23ORM\",\n    \"quantity\": 2\n}"
              },
              "responses": [
                {
                  "status": 201,
                  "headers": {
                    "Content-Type": "application/json"
                  },
                  "body": "{\n    \"status\": \"created\",\n    \"url\": \"/shopping-cart/2\"\n}"
                },
                {
                  "status": 401,
                  "headers": {
                    "Content-Type": "application/json; charset=utf-8"
                  },
                  "body": "{\n    \"message\": \"You have not provided proper request token\"\n}"
                }
              ]
            }
          ]
        },
        {
          "name": "Payment Resources",
          "description": null,
          "resources": [
            {
              "description": "This resource allows you to submit payment information to process your *shopping cart* items",
              "method": "POST",
              "url": "/payment",
              "request": {
                "headers": {},
                "body": "{\n    \"cc\": \"12345678900\",\n    \"cvc\": \"123\",\n    \"expiry\": \"0112\"\n}"
              },
              "responses": [
                {
                  "status": 200,
                  "headers": {},
                  "body": "{\n    \"receipt\": \"/payment/receipt/1\"\n}"
                }
              ]
            },
            {
              "description": null,
              "method": "POST",
              "url": "/resource",
              "request": {
                "headers": {
                  "Content-Type": "application/json"
                },
                "body": "{\n    \"a\": \"b\",\n    \"c\": \"0\"\n}"
              },
              "responses": [
                {
                  "status": 200,
                  "headers": {},
                  "body": "{\n    \"status\": \"ok\"\n}"
                }
              ]
            }
          ]
        }
      ],
      "validations": [
        {
          "method": "POST",
          "url": "/resource",
          "body": "{\n    \"request\": {\n        \"type\": \"object\",\n        \"properties\": {\n            \"a\": {\n                \"type\": \"string\",\n                \"format\": \"alphanumeric\"\n            },\n            \"c\": {\n                \"type\": \"integer\"\n            }\n        }\n    },\n    \"response\": {\n        \"type\": \"object\",\n        \"properties\": {\n            \"status\": {\n                \"type\": \"string\",\n                \"format\": \"alphanumeric\"\n            }\n        }\n    }\n}"
        }
      ]
    }
    """

    Given a file named "apiblueprint_ast.json" with:
    """
    {
      "_version": "1.0",
      "metadata": {
        "HOST": {
          "value": "http://www.google.com/"
        }
      },
      "name": "Sample API v2",
      "description": "Welcome to our sample API documentation. All comments can be written in (support [Markdown](http://daringfireball.net/projects/markdown/syntax) syntax)",
      "resourceGroups": [
        {
          "name": "Shopping Cart Resources",
          "description": "The following is a section of resources related to the shopping cart",
          "resources": [
            {
              "name": null,
              "description": null,
              "uriTemplate": "/shopping-cart",
              "model": null,
              "parameters": null,
              "headers": null,
              "actions": [
                {
                  "name": null,
                  "description": "List products added into your shopping-cart. (comment block again in Markdown)",
                  "method": "GET",
                  "parameters": null,
                  "headers": null,
                  "examples": [
                    {
                      "name": null,
                      "description": null,
                      "requests": null,
                      "responses": [
                        {
                          "name": "200",
                          "description": null,
                          "headers": {
                            "Content-Type": {
                              "value": "application/json"
                            }
                          },
                          "body": "{\n    \"items\": [\n        {\n            \"url\": \"/shopping-cart/1\",\n            \"product\": \"2ZY48XPZ\",\n            \"quantity\": 1,\n            \"name\": \"New socks\",\n            \"price\": 1.25\n        }\n    ]\n}",
                          "schema": null
                        }
                      ]
                    }
                  ]
                },
                {
                  "name": null,
                  "description": "Save new products in your shopping cart",
                  "method": "POST",
                  "parameters": null,
                  "headers": null,
                  "examples": [
                    {
                      "name": null,
                      "description": null,
                      "requests": [
                        {
                          "name": null,
                          "description": null,
                          "headers": {
                            "Content-Type": {
                              "value": "application/json"
                            }
                          },
                          "body": "{\n    \"product\": \"1AB23ORM\",\n    \"quantity\": 2\n}",
                          "schema": null
                        }
                      ],
                      "responses": [
                        {
                          "name": "201",
                          "description": null,
                          "headers": {
                            "Content-Type": {
                              "value": "application/json"
                            }
                          },
                          "body": "{\n    \"status\": \"created\",\n    \"url\": \"/shopping-cart/2\"\n}",
                          "schema": null
                        },
                        {
                          "name": "401",
                          "description": null,
                          "headers": {
                            "Content-Type": {
                              "value": "application/json; charset=utf-8"
                            }
                          },
                          "body": "{\n    \"message\": \"You have not provided proper request token\"\n}",
                          "schema": null
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "name": "Payment Resources",
          "description": null,
          "resources": [
            {
              "name": null,
              "description": null,
              "uriTemplate": "/payment",
              "model": null,
              "parameters": null,
              "headers": null,
              "actions": [
                {
                  "name": null,
                  "description": "This resource allows you to submit payment information to process your *shopping cart* items",
                  "method": "POST",
                  "parameters": null,
                  "headers": null,
                  "examples": [
                    {
                      "name": null,
                      "description": null,
                      "requests": [
                        {
                          "name": null,
                          "description": null,
                          "headers": null,
                          "body": "{\n    \"cc\": \"12345678900\",\n    \"cvc\": \"123\",\n    \"expiry\": \"0112\"\n}",
                          "schema": null
                        }
                      ],
                      "responses": [
                        {
                          "name": "200",
                          "description": null,
                          "headers": null,
                          "body": "{\n    \"receipt\": \"/payment/receipt/1\"\n}",
                          "schema": null
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "name": null,
              "description": null,
              "uriTemplate": "/resource",
              "model": null,
              "parameters": null,
              "headers": null,
              "actions": [
                {
                  "name": null,
                  "description": null,
                  "method": "POST",
                  "parameters": null,
                  "headers": null,
                  "examples": [
                    {
                      "name": null,
                      "description": null,
                      "requests": [
                        {
                          "name": null,
                          "description": null,
                          "headers": {
                            "Content-Type": {
                              "value": "application/json"
                            }
                          },
                          "body": "{\n    \"a\": \"b\",\n    \"c\": \"0\"\n}",
                          "schema": "{\"type\":\"object\",\"properties\":{\"a\":{\"type\":\"string\",\"format\":\"alphanumeric\"},\"c\":{\"type\":\"integer\"}}}"
                        }
                      ],
                      "responses": [
                        {
                          "name": "200",
                          "description": null,
                          "headers": null,
                          "body": "{\n    \"status\": \"ok\"\n}",
                          "schema": "{\"type\":\"object\",\"properties\":{\"status\":{\"type\":\"string\",\"format\":\"alphanumeric\"}}}"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
    """

  Scenario: Convert Legacy Apiary Blueprint AST into API Blueprint AST
    When I run `apiary_blueprint_convertor legacy_ast.json`
    Then the output should contain the content of file "apiblueprint_ast.json"  

  Scenario: Convert Legacy Apiary Blueprint AST on STDIN into API Blueprint AST
    When I run `apiary_blueprint_convertor` interactively
    When I pipe in the file "legacy_ast.json"
    Then the output should contain the content of file "apiblueprint_ast.json"
