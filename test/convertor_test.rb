require 'minitest/autorun'
require 'apiary_blueprint_convertor/convertor'

class ConvertorTest < Minitest::Unit::TestCase
  include ApiaryBlueprintConvertor

  VALIDATIONS_AST = [{
      :url => "/resource2",
      :method => "POST",
      :body => "{ \"request\": \"42\", \"response\": \"0xdeadbeef\" }"
    },
    {
      :url => "/resource1",
      :method => "GET",
      :body => "GOOD STUFF"
    }
  ]

  REQUEST_AST = {
    :headers => nil,
    :body => "A"
  }

  RESPONSES_AST = [{
      :status => 200,
      :headers => {
        :'Content-Type' => "text/plain"
      },
      :body => "Hello World!"
    },
    {
      :status => 404,
      :headers => {
        :'Content-Type' => "application/json",
        :'X-Header' => "42"
      },
      :body => "42 not found."
    }
  ]

  RESOURCES_AST = [{
      :description => "Ipsum Lorem",
      :method => "GET",
      :url => "/resource1",
      :request => REQUEST_AST,
      :responses => []
    },
    {
      :description => nil,
      :method => "POST",
      :url => "/resource2",
      :request => REQUEST_AST,
      :responses => RESPONSES_AST
    },
    {
      :description => nil,
      :method => "PUT",
      :url => "/resource1",
      :request => nil,
      :responses => []
    }    
  ]

  SECTIONS_AST = [{
      :name => "Section One",
      :description => "Lorem Ipsum",
      :resources => []
    },
    {
      :name => "Section TWO",
      :description => nil,
      :resources => RESOURCES_AST
    }
  ]

  BLUEPRINT_AST = {
    :location => "http://google.com",
    :name => "API NAME",
    :description => "Lorem Ipsum",
    :sections => SECTIONS_AST,
    :validations => VALIDATIONS_AST
  }

  def test_convert_location
    blueprint_ast = {}
    Convertor.convert_location("http://google.com", blueprint_ast)

    assert_equal 1, blueprint_ast.keys.length
    assert_equal :metadata, blueprint_ast.keys.first

    assert_equal 1, blueprint_ast[:metadata].keys.length
    assert_equal :HOST, blueprint_ast[:metadata].keys.first

    assert_equal 1, blueprint_ast[:metadata][:HOST].keys.length
    assert_equal :value, blueprint_ast[:metadata][:HOST].keys.first

    assert_equal "http://google.com", blueprint_ast[:metadata][:HOST][:value]
  end

  def test_convert_blueprint
    blueprint_ast = {}
    Convertor.convert_blueprint(BLUEPRINT_AST, blueprint_ast)

    assert_equal 4, blueprint_ast.keys.length

    assert blueprint_ast[:metadata]
    assert_equal "API NAME", blueprint_ast[:name]
    assert_equal "Lorem Ipsum", blueprint_ast[:description]
    assert blueprint_ast[:resourceGroups]
    assert_equal 2, blueprint_ast[:resourceGroups].length

    #puts "\n\n>>#{JSON.pretty_generate(blueprint_ast)}\n"
  end

  def test_convert_sections
    blueprint_ast = {}
    Convertor.convert_sections(SECTIONS_AST, {}, blueprint_ast)

    assert_equal 1, blueprint_ast.keys.length
    assert_equal :resourceGroups, blueprint_ast.keys.first
    assert_instance_of Array, blueprint_ast[:resourceGroups]
    assert_equal 2, blueprint_ast[:resourceGroups].length

    assert_equal "Section One", blueprint_ast[:resourceGroups][0][:name]
    assert_equal "Lorem Ipsum", blueprint_ast[:resourceGroups][0][:description]
    assert_equal nil, blueprint_ast[:resourceGroups][0][:resources]

    assert_equal "Section TWO", blueprint_ast[:resourceGroups][1][:name]
    assert_equal nil, blueprint_ast[:resourceGroups][1][:description]
    assert_instance_of Array, blueprint_ast[:resourceGroups][1][:resources]
    assert_equal 2, blueprint_ast[:resourceGroups][1][:resources].length
  end

  def test_convert_resources
    group_ast = {}
    Convertor.convert_resources(RESOURCES_AST, {}, group_ast)

    assert_equal 1, group_ast.keys.length
    assert_equal :resources, group_ast.keys.first
    assert_instance_of Array, group_ast[:resources]
    assert_equal 2, group_ast[:resources].length

    assert_equal nil, group_ast[:resources][0][:name]
    assert_equal nil, group_ast[:resources][0][:description]
    assert_equal "/resource1", group_ast[:resources][0][:uriTemplate]
    assert_equal nil, group_ast[:resources][0][:model]
    assert_equal nil, group_ast[:resources][0][:parameters]
    assert_equal nil, group_ast[:resources][0][:headers]
    assert group_ast[:resources][0][:actions]
    assert_equal 2, group_ast[:resources][0][:actions].length

    assert_equal nil, group_ast[:resources][1][:name]
    assert_equal nil, group_ast[:resources][1][:description]
    assert_equal "/resource2", group_ast[:resources][1][:uriTemplate]
    assert_equal nil, group_ast[:resources][1][:model]
    assert_equal nil, group_ast[:resources][1][:parameters]
    assert_equal nil, group_ast[:resources][1][:headers]
    assert group_ast[:resources][1][:actions]
    assert_equal 1, group_ast[:resources][1][:actions].length
  end

  def test_add_resource_action
    resource_ast = {}
    Convertor.add_resource_action(RESOURCES_AST[0], {}, resource_ast)

    assert resource_ast[:actions], "resource actions exists"
    assert_equal 1, resource_ast[:actions].length
    assert_equal "GET", resource_ast[:actions][0][:method]
    assert_equal "Ipsum Lorem", resource_ast[:actions][0][:description]
    assert_equal nil, resource_ast[:actions][0][:parameters]
    assert_equal nil, resource_ast[:actions][0][:headers]
    assert_instance_of Array, resource_ast[:actions][0][:examples]
  end

  def test_add_action_example
    action_ast = {}
    Convertor.add_action_example(RESOURCES_AST[1], VALIDATIONS_AST, action_ast)
    
    assert_instance_of Array, action_ast[:examples]
    assert_equal 1, action_ast[:examples].length
    assert_equal nil, action_ast[:examples][0][:name]
    assert_equal nil, action_ast[:examples][0][:description]
    
    assert_instance_of Array, action_ast[:examples][0][:requests]
    assert_equal 1, action_ast[:examples][0][:requests].length
    assert_equal nil, action_ast[:examples][0][:requests][0][:name]
    assert_equal nil, action_ast[:examples][0][:requests][0][:description]
    assert_equal nil, action_ast[:examples][0][:requests][0][:headers]
    assert_equal "A", action_ast[:examples][0][:requests][0][:body]
    assert_equal "42", action_ast[:examples][0][:requests][0][:schema]

    assert_instance_of Array, action_ast[:examples][0][:responses]
    assert_equal 2, action_ast[:examples][0][:responses].length

    assert_equal "200", action_ast[:examples][0][:responses][0][:name]
    assert_equal nil, action_ast[:examples][0][:responses][0][:description]
    
    assert_instance_of Hash, action_ast[:examples][0][:responses][0][:headers]
    assert_equal 1, action_ast[:examples][0][:responses][0][:headers].keys.length
    assert_equal :'Content-Type', action_ast[:examples][0][:responses][0][:headers].keys[0]
    assert_instance_of Hash, action_ast[:examples][0][:responses][0][:headers][:'Content-Type']
    assert_equal 1, action_ast[:examples][0][:responses][0][:headers][:'Content-Type'].keys.length
    assert_equal :value, action_ast[:examples][0][:responses][0][:headers][:'Content-Type'].keys[0]
    assert_equal "text/plain", action_ast[:examples][0][:responses][0][:headers][:'Content-Type'][:value]

    assert_equal "Hello World!", action_ast[:examples][0][:responses][0][:body]
    assert_equal "0xdeadbeef", action_ast[:examples][0][:responses][0][:schema]

    assert_equal "404", action_ast[:examples][0][:responses][1][:name]
    assert_equal nil, action_ast[:examples][0][:responses][1][:description]

    assert_instance_of Hash, action_ast[:examples][0][:responses][1][:headers]
    assert_equal 2, action_ast[:examples][0][:responses][1][:headers].keys.length
    
    assert_equal :'Content-Type', action_ast[:examples][0][:responses][1][:headers].keys[0]
    assert_instance_of Hash, action_ast[:examples][0][:responses][1][:headers][:'Content-Type']
    assert_equal 1, action_ast[:examples][0][:responses][1][:headers][:'Content-Type'].keys.length
    assert_equal :value, action_ast[:examples][0][:responses][1][:headers][:'Content-Type'].keys[0]
    assert_equal "application/json", action_ast[:examples][0][:responses][1][:headers][:'Content-Type'][:value]

    assert_equal :'X-Header', action_ast[:examples][0][:responses][1][:headers].keys[1]
    assert_instance_of Hash, action_ast[:examples][0][:responses][1][:headers][:'X-Header']
    assert_equal 1, action_ast[:examples][0][:responses][1][:headers][:'X-Header'].keys.length
    assert_equal :value, action_ast[:examples][0][:responses][1][:headers][:'X-Header'].keys[0]
    assert_equal "42", action_ast[:examples][0][:responses][1][:headers][:'X-Header'][:value]

    assert_equal "42 not found.", action_ast[:examples][0][:responses][1][:body]
    assert_equal "0xdeadbeef", action_ast[:examples][0][:responses][1][:schema]
  end
end











