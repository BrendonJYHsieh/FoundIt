# FoundIt User Stories

## Epic 1: User Registration & Authentication
As a Columbia University student, I want to register with my .edu email so that I can access the trusted student-only network.

### User Story 1.1: Student Registration
**As a** Columbia University student  
**I want to** register with my Columbia email address  
**So that** I can access the FoundIt platform securely  

**Acceptance Criteria:**
- [ ] I can register with a valid Columbia .edu email address
- [ ] I receive a verification email to confirm my account
- [ ] I cannot register with non-Columbia email addresses
- [ ] I must provide my UNI (University Network ID) for verification

### User Story 1.2: User Login
**As a** registered Columbia student  
**I want to** log into my account securely  
**So that** I can access my lost/found items  

**Acceptance Criteria:**
- [ ] I can log in with my verified email and password
- [ ] I am redirected to my dashboard after successful login
- [ ] Failed login attempts are logged for security
- [ ] I can reset my password if forgotten

## Epic 2: Lost Item Management
As a student who lost something, I want to post details about my lost item so that the system can help me find it.

### User Story 2.1: Post Lost Item
**As a** student who lost an item  
**I want to** create a detailed post about my lost item  
**So that** the system can match it with found items  

**Acceptance Criteria:**
- [ ] I can select the item type from predefined categories (phone, laptop, textbook, ID, keys, etc.)
- [ ] I can add a detailed description of the item
- [ ] I can specify where I last saw it (campus location)
- [ ] I can select the approximate date/time I lost it
- [ ] I can upload photos of the item (optional)
- [ ] I can set verification questions for potential finders
- [ ] The post is immediately searchable by the matching algorithm

### User Story 2.2: View Lost Item Matches
**As a** student who posted a lost item  
**I want to** see potential matches from found items  
**So that** I can identify if someone found my item  

**Acceptance Criteria:**
- [ ] I receive instant notifications when potential matches are found
- [ ] I can view 3-5 curated suggestions instead of scrolling through hundreds
- [ ] Each match shows similarity score and key details
- [ ] I can click on matches to see full details
- [ ] I can mark matches as "not my item" to improve future suggestions

### User Story 2.3: Manage Lost Item Posts
**As a** student who posted a lost item  
**I want to** manage my lost item posts  
**So that** I can keep them updated and relevant  

**Acceptance Criteria:**
- [ ] I can view all my active lost item posts
- [ ] I can edit details of my posts
- [ ] I can mark items as "found" when recovered
- [ ] I can delete posts that are no longer relevant
- [ ] I can extend the search period for high-value items

## Epic 3: Found Item Management
As a student who found something, I want to post details about the found item so that I can return it to its rightful owner.

### User Story 3.1: Post Found Item
**As a** student who found an item  
**I want to** create a post about the found item  
**So that** I can help return it to its owner  

**Acceptance Criteria:**
- [ ] I can select the item type from predefined categories
- [ ] I can add a description of the found item
- [ ] I can specify where I found it (campus location)
- [ ] I can select the date/time I found it
- [ ] I must upload at least one photo proving I have the item
- [ ] I can add additional details about the item's condition
- [ ] The post is immediately searchable by the matching algorithm

### User Story 3.2: Respond to Verification Questions
**As a** student who found an item  
**I want to** answer verification questions from potential owners  
**So that** I can confirm I have the right item before meeting  

**Acceptance Criteria:**
- [ ] I receive notifications when someone claims the item
- [ ] I can see the verification questions set by the potential owner
- [ ] I can answer the questions to prove I have the correct item
- [ ] Only verified matches can proceed to contact me
- [ ] I can decline matches if I don't have the right item

### User Story 3.3: Manage Found Item Posts
**As a** student who posted a found item  
**I want to** manage my found item posts  
**So that** I can track returns and maintain my reputation  

**Acceptance Criteria:**
- [ ] I can view all my active found item posts
- [ ] I can see the status of each post (waiting for owner, verified match, returned)
- [ ] I can mark items as "returned" when successfully given back
- [ ] I can delete posts for items I no longer have
- [ ] I can see my "Good Samaritan" reputation score

## Epic 4: Smart Matching & Verification
As a user of the platform, I want the system to intelligently match lost and found items so that reunions happen efficiently and securely.

### User Story 4.1: Automatic Item Matching
**As a** user of the platform  
**I want** the system to automatically find potential matches  
**So that** I don't have to manually search through hundreds of posts  

**Acceptance Criteria:**
- [ ] The system compares item type, location, and date automatically
- [ ] Matches are ranked by similarity score
- [ ] Only the top 3-5 matches are shown to users
- [ ] The algorithm learns from user feedback to improve accuracy
- [ ] Matches are found within seconds of posting

### User Story 4.2: Verification System
**As a** user claiming an item  
**I want** to answer verification questions before contacting the finder  
**So that** I can prove I'm the rightful owner  

**Acceptance Criteria:**
- [ ] I must answer verification questions correctly before contact is made
- [ ] Questions are set by the original poster (lost item owner)
- [ ] I have 3 attempts to answer correctly
- [ ] Only after verification can I see contact information
- [ ] Failed verification attempts are logged for security

### User Story 4.3: Privacy Protection
**As a** user of the platform  
**I want** my contact information to remain private until verification  
**So that** I'm protected from scammers and unwanted contact  

**Acceptance Criteria:**
- [ ] No contact information is shared until verification passes
- [ ] All communication happens through the platform initially
- [ ] Users can choose to share contact info after successful verification
- [ ] Personal details are never exposed in public posts

## Epic 5: Communication & Coordination
As a user who has a verified match, I want to communicate safely with the other party so that we can arrange the return of the item.

### User Story 5.1: In-App Messaging
**As a** user with a verified match  
**I want to** message the other party through the platform  
**So that** I can coordinate the return without exposing my phone number  

**Acceptance Criteria:**
- [ ] I can send messages to verified matches only
- [ ] Messages are delivered instantly
- [ ] I can see message history
- [ ] I can attach photos if needed
- [ ] Messages are encrypted and secure

### User Story 5.2: Safe Meetup Coordination
**As a** user coordinating an item return  
**I want to** arrange safe meeting locations  
**So that** both parties feel secure during the exchange  

**Acceptance Criteria:**
- [ ] I can see suggested safe meeting spots on campus
- [ ] I can choose from public locations (library, student center, etc.)
- [ ] I can involve campus security for high-value items
- [ ] I can schedule meeting times through the platform
- [ ] Both parties receive meeting reminders

### User Story 5.3: Reputation System
**As a** user of the platform  
**I want to** build a reputation for being trustworthy  
**So that** other users feel confident interacting with me  

**Acceptance Criteria:**
- [ ] I earn "Good Samaritan" badges for successful returns
- [ ] My reputation score is visible to other users
- [ ] Users can rate their experience after item returns
- [ ] High-reputation users get priority in matching
- [ ] Negative feedback is investigated by moderators

## Epic 6: Campus Integration
As a Columbia University student, I want the platform to integrate with campus services so that I have additional security and support.

### User Story 6.1: Campus Location Integration
**As a** Columbia student  
**I want to** use familiar campus locations in my posts  
**So that** other students can easily understand where items were lost/found  

**Acceptance Criteria:**
- [ ] I can select from predefined Columbia locations (Butler Library, Lerner Hall, etc.)
- [ ] Locations are organized by building and floor
- [ ] Popular locations are suggested based on usage
- [ ] I can add specific details (room numbers, landmarks)

### User Story 6.2: Security Integration
**As a** user dealing with high-value items  
**I want to** involve campus security when needed  
**So that** I have additional protection during exchanges  

**Acceptance Criteria:**
- [ ] I can request security presence for valuable items
- [ ] Campus security can be notified of scheduled exchanges
- [ ] Security can verify item ownership if disputes arise
- [ ] Integration with Columbia's existing security systems

## Epic 7: Mobile Experience
As a student on the go, I want to access FoundIt from my mobile device so that I can post and respond to items anywhere on campus.

### User Story 7.1: Mobile-Optimized Interface
**As a** mobile user  
**I want to** use FoundIt easily on my phone  
**So that** I can post items immediately when I find them  

**Acceptance Criteria:**
- [ ] The interface is responsive and mobile-friendly
- [ ] I can easily upload photos from my phone camera
- [ ] Touch interactions work smoothly
- [ ] The app loads quickly on mobile networks
- [ ] Push notifications work on mobile devices

### User Story 7.2: Location Services
**As a** mobile user  
**I want to** use my phone's location services  
**So that** I can automatically detect where I am on campus  

**Acceptance Criteria:**
- [ ] I can enable location services for automatic location detection
- [ ] Campus locations are suggested based on my current location
- [ ] I can manually override the detected location
- [ ] Location data is only used for campus-specific features

## Epic 8: Admin & Moderation
As a platform administrator, I want to monitor and moderate the platform so that it remains safe and useful for all Columbia students.

### User Story 8.1: Content Moderation
**As a** platform administrator  
**I want to** review and moderate posts  
**So that** inappropriate content is removed quickly  

**Acceptance Criteria:**
- [ ] I can view all reported posts
- [ ] I can remove inappropriate content
- [ ] I can suspend users who violate terms
- [ ] I can restore posts that were incorrectly flagged
- [ ] Moderation actions are logged and auditable

### User Story 8.2: Analytics & Reporting
**As a** platform administrator  
**I want to** view platform analytics  
**So that** I can understand usage patterns and improve the service  

**Acceptance Criteria:**
- [ ] I can see daily/weekly/monthly usage statistics
- [ ] I can track successful item returns
- [ ] I can identify popular locations and item types
- [ ] I can generate reports for university administration
- [ ] Analytics help identify areas for improvement
