package com.jfrog.controller;

import com.jfrog.domain.User;
import com.jfrog.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@RestController()
@RequestMapping("/api")
public class BackendController {

    private static final Logger LOG = LoggerFactory.getLogger(BackendController.class);

    static final String HELLO_TEXT = "Hello from Spring Boot Backend!";

    private final RestTemplate restTemplate;

    private final UserRepository userRepository;

    private final Environment environment;

    @Autowired
    public BackendController(RestTemplate restTemplate, UserRepository userRepository, Environment environment) {
        this.restTemplate = restTemplate;
        this.userRepository = userRepository;
        this.environment = environment;
    }

    @RequestMapping(path = "/hello")
    public @ResponseBody String sayHello() {
        LOG.info("GET called on /hello resource");
        return HELLO_TEXT;
    }

    @RequestMapping(path = "/user", method = RequestMethod.POST)
    @ResponseStatus(HttpStatus.CREATED)
    public @ResponseBody long addNewUser (@RequestParam String firstName, @RequestParam String lastName) {
        User user = new User(firstName, lastName);
        userRepository.save(user);

        LOG.info(user.toString() + " successfully saved into DB");

        return user.getId();
    }

    @GetMapping(path="/users")
    public @ResponseBody
    List<User> getUsers() {
        LOG.info("Reading users from database.");
        List<User> users = new ArrayList<>();
        userRepository.findAll().forEach(users::add);

        return users;
    }

    @GetMapping(path="/user/{id}")
    public @ResponseBody User getUserById(@PathVariable("id") long id) {
        LOG.info("Reading user with id " + id + " from database.");
        return userRepository.findById(id).get();
    }

    @GetMapping(path="/service")
    public @ResponseBody String callGoService() {
        ResponseEntity<String> responseEntity = restTemplate.exchange("http://" + environment.getProperty("GO_SERVICE_ADDRESS")
                + ":3000/", HttpMethod.GET, null, new ParameterizedTypeReference<String>() {});

        return responseEntity.getBody();
    }

}
