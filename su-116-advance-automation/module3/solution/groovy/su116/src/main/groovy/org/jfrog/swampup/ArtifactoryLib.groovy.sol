package org.jfrog.swampup

import org.jfrog.artifactory.client.Artifactory
import org.jfrog.artifactory.client.ArtifactoryClientBuilder
import org.jfrog.artifactory.client.model.User
import org.jfrog.artifactory.client.model.builder.UserBuilder

/**
 * Created by stanleyf on 25/05/2019.
 */
class ArtifactoryLib {
    private Artifactory art
    String credentials

    ArtifactoryLib (def artUrl, String user, String password) {
        art = createArtifactoryClient(artUrl, user, password)
        this.credentials = "${user}:${password}"
    }

    void createRepo(String yamlPath) {
        def url = "${art.getUri()}/artifactory/api/system/configuration"
        def request = ["curl", "-s", "-u", credentials, "-X", "PATCH", "-H", "Content-Type: application/yaml", url, "-T", yamlPath ];
        assert artifactoryRequest(request) : "Fail to create repositories; Request: ${request}"
    }

    void createUser (String user, String password) {
        def email = "${user}.jfrog.com"
        def admin = true
        usersCreate(user, password, email, admin)
    }

    private void usersCreate (String user, String password, String email, boolean admin) {
        UserBuilder ub = art.security().builders().userBuilder()
        User userId = ub.name(user)
                .email(email)
                .admin(admin)
                .profileUpdatable(true)
                .password(password)
                .build()
        art.security().createOrUpdate(userId)
    }

    static private Artifactory createArtifactoryClient (def artUrl, String user, String password ) {
        return ArtifactoryClientBuilder.create()
                .setUrl(artUrl)
                .setUsername(user)
                .setPassword(password)
                .setConnectionTimeout(0)
                .setSocketTimeout(0)
                .build()
    }

    static private boolean artifactoryRequest (def request) {
        try {
            def proc = request.execute();
            Thread.start { System.err << proc.err }
            proc.waitFor();
            if (proc.exitValue() != 0) {
                println("Artifactory returns errors with repository creation or deletion; Error: ${proc.exitValue()}");
                return false;
            }
        } catch (Exception ex) {
            println "Exception caught while working with repositories; Message: ${ex.toString()}";
            return false;
        }
        return true;
    }
}
