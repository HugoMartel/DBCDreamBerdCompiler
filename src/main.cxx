/**
 * @file
 */
#include <iostream>

#include "antlr4-runtime.h"
#include "CCCLexer.h"
#include "CCCParser.h"


int 
main(int argc, const char* argv[])
{
    std::ifstream stream;
    //stream.open(argv[1]);

    antlr4::ANTLRInputStream input(std::cin);
    CCCLexer lexer(&input);
    antlr4::CommonTokenStream tokens(&lexer);
    CCCParser parser(&tokens);    

    CCCParser::FileContext* tree = parser.file();

    std::cout << "TODO\n";

    return 0;
}
