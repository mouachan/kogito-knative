package org.redhat.listeners;

import javax.enterprise.context.ApplicationScoped;

import org.drools.core.config.DefaultRuleEventListenerConfig;
import org.kie.addons.monitoring.rule.PrometheusMetricsDroolsListener;

@ApplicationScoped
public class DiscountEventListenerConfig extends DefaultRuleEventListenerConfig {

    public DiscountEventListenerConfig() {
        super( new PrometheusMetricsDroolsListener("ff-discount"));
    }
}