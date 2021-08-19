package com.redhat.coolstore;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Readiness;

@Readiness
@ApplicationScoped
public class InventoryHealthCheck implements HealthCheck {

    @Inject
    private InventoryResource inventoryResource;

    @Override
    public HealthCheckResponse call() {

        if (inventoryResource.getAll() != null) {
            return HealthCheckResponse.named("Success of Inventory Health Check!!!").up().build();
        } else {
            return HealthCheckResponse.named("Failure of Inventory Health Check!!!").down().build();
        }
    }
}