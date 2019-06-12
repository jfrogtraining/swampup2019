package com.jfrog.repository;

import com.jfrog.domain.User;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.List;

import static org.hamcrest.Matchers.contains;
import static org.junit.Assert.*;

@RunWith(SpringRunner.class)
@DataJpaTest
public class UserRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private UserRepository users;

    private User fooUser = new User("Foo", "Foo");
    private User barUser = new User("Bar", "Bar");

    @Before
    public void fillSomeDataIntoOurDb() {
        // Add new Users to Database
        entityManager.persist(fooUser);
        entityManager.persist(barUser);
    }

    @Test
    public void testFindByLastName() {
        // Search for specific User in Database according to lastname
        List<User> usersWithLastNameBar = users.findByLastName("Bar");

        assertThat(usersWithLastNameBar, contains(barUser));
    }


    @Test
    public void testFindByFirstName() {
        // Search for specific User in Database according to firstname
        List<User> usersWithFirstNameFoo = users.findByFirstName("Foo");

        assertThat(usersWithFirstNameFoo, contains(fooUser));
    }

}