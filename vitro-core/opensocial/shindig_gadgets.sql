LOCK TABLES `orng_apps` WRITE;
/*!40000 ALTER TABLE `orng_apps` DISABLE KEYS */;
INSERT INTO `orng_apps` VALUES 
(100,'Google Search','http://localhost:8080/gadgets/GoogleSearch.xml',NULL,0,NULL),
(101,'Featured Presentations','http://localhost:8080/gadgets/SlideShare.xml',NULL,1,NULL),
(102,'Faculty Mentor','http://profiles.ucsf.edu/apps_2.1/Mentor.xml',NULL,0,NULL),
(103,'Websites','http://profiles.ucsf.edu/apps_2.1/Links.xml',NULL,0,NULL),
(104,'Profile List','http://profiles.ucsf.edu/apps_2.1/ProfileListTool.xml',NULL,0,'JSONPersonIds'),
(106,'RDF Test Gadget','http://profiles.ucsf.edu/apps_2.1/RDFTest.xml',NULL,0,NULL),
(112,'Twitter','http://localhost:8080/gadgets/Twitter.xml',NULL,1,NULL),
(113,'YouTube','http://localhost:8080/gadgets/YouTube.xml',NULL,1,NULL),
(111,'LinkedIn','http://localhost:8080/gadgets/LinkedIn.xml',NULL,1,NULL),
(114,'Scopus H-Index','http://localhost:8080/gadgets/Scopus.xml',NULL,1,NULL),
(115,'The Conversation','http://localhost:8080/gadgets/TheConversation.xml',NULL,1,NULL);
/*!40000 ALTER TABLE `orng_apps` ENABLE KEYS */;
UNLOCK TABLES;


LOCK TABLES `orng_app_views` WRITE;
/*!40000 ALTER TABLE `orng_app_views` DISABLE KEYS */;
INSERT INTO `orng_app_views` VALUES 
(100,NULL,NULL,'search',NULL,'gadgets-search',NULL,NULL),
(101,NULL,'R','individual','profile','gadgets-view',4,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':0, \'closed_width\':700}'),
(101,NULL,NULL,'individual-EDIT-MODE','home','gadgets-edit',4,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':700}'),
(102,NULL,'R','individual','profile','gadgets-view',3,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':290}'),
(102,NULL,NULL,'individual-EDIT-MODE','home','gadgets-edit',3,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':700}'),
(103,NULL,NULL,'individual-EDIT-MODE','home','gadgets-edit',NULL,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':700}'),
(103,NULL,'R','individual','profile','gadgets-view',1,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':0, \'closed_width\':290}'),
(104,'U',NULL,'search','small','gadgets-tools',NULL,NULL),
(104,'U',NULL,'gadgetDetails','canvas','gadgets-detail',NULL,NULL),
(104,'U',NULL,'individual','small','gadgets-view',NULL,NULL),
(106,NULL,NULL,'individual-EDIT-MODE','home','gadgets-edit',NULL,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':700}'),
(111,NULL,'R','individual','profile','gadgets-view',5,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':0, \'closed_width\':700}'),
(111,NULL,NULL,'individual-EDIT-MODE','home','gadgets-edit',5,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':700}'),
(112,NULL,'R','individual','profile','gadgets-view',2,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':0, \'closed_width\':700}'),
(112,NULL,NULL,'individual-EDIT-MODE','home','gadgets-edit',2,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':700}'),
(113,NULL,'R','individual','profile','gadgets-view',4,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':0, \'closed_width\':700}'),
(113,NULL,NULL,'individual-EDIT-MODE','home','gadgets-edit',4,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':700}'),
(114,NULL,'R','individual','profile','gadgets-view',4,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':0, \'closed_width\':700}'),
(114,NULL,NULL,'individual-EDIT-MODE','home','gadgets-edit',4,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':700}'),
(115,NULL,'R','individual','profile','gadgets-view',4,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':0, \'closed_width\':700}'),
(115,NULL,NULL,'individual-EDIT-MODE','home','gadgets-edit',4,'{\'gadget_class\':\'ORNGToggleGadget\', \'start_closed\':1, \'closed_width\':700}');
/*!40000 ALTER TABLE `orng_app_views` ENABLE KEYS */;
UNLOCK TABLES;
