/**
 * @file
 */

#include <iostream>


#define CATCH_CONFIG_MAIN
#include "catch_amalgamated.hpp"

#include "parser.yy.hpp"


/*------------------------*/
/*       UNIT TESTS       */
/*------------------------*/
/*
TEST_CASE( "name", "[object tested]" )
{

    REQUIRE( functiontoTest == TheoricalResult );

}
*/

TEST_CASE("Sample Test", "[Sample]")
{
    output = "gaga";
    REQUIRE( output == "" );

    REQUIRE( output == "gaga" );
}

