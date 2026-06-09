#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.get()

println "--> creating local admin user"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount(
    "admin",
    "admin123"
)

instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()

strategy.setAllowAnonymousRead(false)

instance.setAuthorizationStrategy(strategy)

instance.save()

println "--> admin user created"