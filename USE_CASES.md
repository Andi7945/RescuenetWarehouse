# RescuenetWarehouse Use Cases

This document defines the core use cases for the RescuenetWarehouse application to guide comprehensive testing and prevent regressions.

## User Roles

### Packer
- Verify container contents match system records
- Check for dangerous goods and broken equipment  
- Mark containers as ready for deployment
- Print packing lists, labels, and summary sheets

### Back Office
- Add and modify item metadata
- Create and manage containers
- Import/export item data
- Manage reference data (container types, locations, destinations)

### Logistics
- All Packer and Back Office capabilities
- Coordinate deployments and assignments

### On Deployment
- Mark items as used post-deployment
- Update container status after missions
- Track equipment losses and damage

## Core Use Cases

### UC01: Authentication & Access Control
**Primary Actor:** All Users
**Goal:** Secure access with appropriate role permissions

**Main Flow:**
1. User navigates to application
2. User enters credentials (must be @rescuenet.net email)
3. System authenticates and redirects to main application
4. User accesses features based on role permissions

**Alternate Flows:**
- Registration for new users
- Password reset functionality
- Invalid email domain rejection

### UC02: Item Management
**Primary Actor:** Back Office, Logistics
**Goal:** Maintain accurate inventory of equipment and supplies

**Main Flow:**
1. User navigates to items overview
2. User can filter/sort items by various criteria
3. User selects item to view/edit details
4. User modifies item information (name, description, amounts, dangerous goods, expiry dates)
5. System saves changes and updates assignments

**Sub-flows:**
- **UC02a:** Add new item with complete metadata
- **UC02b:** Bulk import items from CSV
- **UC02c:** Export items to CSV/PDF
- **UC02d:** Delete multiple items (with usage validation)
- **UC02e:** Manage dangerous goods classifications
- **UC02f:** Track expiry dates and generate alerts

### UC03: Container Management  
**Primary Actor:** Back Office, Logistics
**Goal:** Manage physical storage containers and their capacity

**Main Flow:**
1. User navigates to container overview
2. User views container list with current status
3. User selects container to edit details
4. User modifies container information (type, location, destination, weight limits)
5. System validates capacity constraints and saves changes

**Sub-flows:**
- **UC03a:** Create new container with type and specifications
- **UC03b:** Manage container types with empty weights and measurements
- **UC03c:** Set container locations and module destinations
- **UC03d:** Monitor container weight and capacity utilization

### UC04: Assignment Management
**Primary Actor:** Back Office, Logistics
**Goal:** Assign items to containers for deployment

**Item-Centric Flow:**
1. User selects item from inventory
2. System shows current assignments across containers
3. User adds/modifies quantities in specific containers
4. System validates capacity constraints
5. System updates assignments and container weights

**Container-Centric Flow:**
1. User selects container
2. System shows currently assigned items
3. User searches and adds items to container
4. User adjusts quantities for optimal packing
5. System validates total weight and capacity

### UC05: Deployment Preparation (Packer Workflows)
**Primary Actor:** Packer, Logistics
**Goal:** Verify and prepare containers for deployment

**Main Flow:**
1. Packer selects container for verification
2. System displays assigned items and quantities
3. Packer physically verifies contents match system
4. Packer checks for dangerous goods compliance
5. Packer inspects equipment condition
6. Packer marks container as verified and ready
7. System generates packing list, labels, and summary sheets

**Sub-flows:**
- **UC05a:** Print container-specific packing lists
- **UC05b:** Generate dangerous goods documentation
- **UC05c:** Create summary reports for logistics coordination
- **UC05d:** Print container labels with QR codes

### UC06: Post-Deployment Processing
**Primary Actor:** On Deployment, Logistics
**Goal:** Update inventory after mission completion

**Main Flow:**
1. User selects deployed containers
2. System shows pre-deployment contents
3. User marks items as: returned, used/consumed, damaged, lost
4. User updates quantities for returned items
5. System adjusts inventory levels and generates work log entries

### UC07: Reference Data Management
**Primary Actor:** Back Office, Logistics
**Goal:** Maintain supporting data for operations

**Sub-flows:**
- **UC07a:** Manage container types (add, edit, delete with usage validation)
- **UC07b:** Manage current locations
- **UC07c:** Manage module destinations  
- **UC07d:** Configure dangerous goods signs and classifications

### UC08: Reporting & Analytics
**Primary Actor:** All Users
**Goal:** Generate insights and documentation

**Main Flow:**
1. User selects reporting function
2. User configures report parameters (date range, filters)
3. System generates requested report
4. User exports or prints report

**Sub-flows:**
- **UC08a:** Work log reports showing all operations
- **UC08b:** Container utilization analytics
- **UC08c:** Item usage tracking
- **UC08d:** Expiry date monitoring reports

### UC09: Data Import/Export
**Primary Actor:** Back Office, Logistics
**Goal:** Integrate with external systems and backup data

**Main Flow:**
1. User initiates import/export operation
2. User selects data format and scope
3. System processes data with validation
4. System provides feedback on success/failures
5. User reviews and confirms changes

**Sub-flows:**
- **UC09a:** CSV import with diff preview
- **UC09b:** Bulk data export for backup
- **UC09c:** Firebase data import using firestore commands

## Error Scenarios & Edge Cases

### Data Consistency
- Container capacity exceeded during assignment
- Item assignments exceed available inventory
- Concurrent edits by multiple users
- Network connectivity loss during operations

### Validation Failures
- Invalid dangerous goods classifications
- Expired items in active assignments  
- Missing required fields in forms
- File format errors during import

### Permission Scenarios
- Role-based access enforcement
- Unauthorized operation attempts
- Session timeout handling

## Success Criteria

Each use case should be testable with:
1. **Happy path** - Normal successful execution
2. **Alternative paths** - Valid variations in user flow
3. **Error conditions** - System handles failures gracefully
4. **Boundary conditions** - Limits and constraints are enforced
5. **Performance criteria** - Operations complete within acceptable time
6. **Data integrity** - Changes persist correctly across sessions