package com.redhat.coolstore;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.containsString;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

@QuarkusTest
public class InventoryEndpointTest {

    @Test
    public void testListAllInventory() {
        //List all, should have all 8 cities inventory the database has initially:
        given()
              .when().get("/services/inventory")
              .then()
              .statusCode(200)
              .body(
                    containsString("Raleigh"),
                    containsString("Boston"),
                    containsString("Seoul"),
                    containsString("Singapore"),
                    containsString("London"),
                    containsString("NewYork"),
                    containsString("Paris"),
                    containsString("Tokyo")
                    );
     
        //List a certain item(ID:329299), Raleigh should be returned:
        given()
        .when().get("/services/inventory/329299")
        .then()
        .statusCode(200)
        .body(                   
              containsString("Raleigh")
        );
    }

}
