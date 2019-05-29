package org.jfrog.swampup


/**
 * Created by stanleyf on 25/05/2019.
 */
class Module3 {
    static def swamupArt = System.getProperty("artifactoryUrl")
    static def user = System.getProperty("art.user")
    static def password = System.getProperty("art.password")
    static def repoYaml = System.getProperty("repo.config")
    static ArtifactoryLib artl

    public static void main (String [] args) {
        println "Exercise 3a - Create User and Repositories"
        artl = new ArtifactoryLib(swamupArt, user, password)
        artl.createUser("swampupdev2019", "9YF*9@UT4Ca^CDeF")
        artl.createUser("swampupops2019", "9YF*9@UT4Ca^CDeF")
        artl.createRepo(repoYaml)
    }
}
