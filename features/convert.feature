Feature: Convert AST

  Background: 
    Given a file named "legacy_ast.json" with:
    """
    """

    Given a file named "apiblueprint_ast.json" with:
    """
    """

  Scenario: Convert Legacy Apiary Blueprint AST into API Blueprint AST
    When I run `apiary_blueprint_convertor legacy_ast.json`
    Then the output should contain the content of file "apiblueprint_ast.json"  

  Scenario: Convert Legacy Apiary Blueprint AST on STDIN into API Blueprint AST
    When I run `apiary_blueprint_convertor` interactively
    When I pipe in the file "legacy_ast.json"
    Then the output should contain the content of file "apiblueprint_ast.json"
