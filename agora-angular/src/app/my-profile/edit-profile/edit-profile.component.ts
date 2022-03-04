import { Component, EventEmitter, Input, OnChanges, OnInit, Output } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { faEnvelope, faLink, faLocationArrow, faCalendarAlt, faCamera, faSave, faSpinner } from '@fortawesome/free-solid-svg-icons';
import { from } from 'rxjs';
import { User, seller, UserService } from "../../services/user.service";

@Component({
  selector: 'edit-profile',
  templateUrl: './edit-profile.component.html',
  styleUrls: ['./edit-profile.component.scss']
})
export class EditProfileComponent implements OnChanges {

  faEnvelope = faEnvelope;
  faLink = faLink;
  faLocationArrow = faLocationArrow;
  faCalendar = faCalendarAlt;
  faCamera = faCamera;
  faSave = faSave;
  faSpinner = faSpinner;

  @Input() user: User = new User();
  @Input() isBackVisible: boolean = true;
  @Output() modalState = new EventEmitter<boolean>();
  @Output() userChange = new EventEmitter<User>();
  isLoading:boolean = false;

  constructor(
    private fb: FormBuilder,
    private userService:UserService,
  ) { }

  userForm = this.fb.group({
    firstName: [this.user.firstName, Validators.required],
    lastName: [this.user.lastName, Validators.required],
    companyName: [this.user.companyName],
    siteLocation: [this.user.siteLocation],
    website: [this.user.website],
    about: [this.user.about],
    takesCustomOrders: [this.user.takesCustomOrders]
  });

  back($event: any) {
    $event.preventDefault();
    this.modalState.emit(false);
  }

  save($event: any) {
    $event.preventDefault();
    if (!this.userForm.valid) return;
    this.isLoading = true;
    let updatedUser: User = this.user;
    let form = this.userForm.value;
    updatedUser.firstName = form.firstName;
    updatedUser.lastName = form.lastName;
    updatedUser.companyName = form.companyName == '' ? null : form.companyName;
    updatedUser.siteLocation = form.siteLocation == '' ? null : form.siteLocation;
    updatedUser.website = form.website == '' ? null : form.website;
    updatedUser.about = form.about == '' ? null : form.about;
    updatedUser.takesCustomOrders = form.takesCustomOrders;
    this.userService.updateUser(updatedUser).subscribe({
      next: () => {
        this.isLoading = false;
        this.userChange.emit(updatedUser);
        this.modalState.emit(false);
      }
    })
  }

  ngOnChanges(): void {
    let form = this.userForm.value;
    form.firstName = this.user.firstName;
    form.lastName = this.user.lastName;
    form.companyName = this.user.companyName ? this.user.companyName : '';
    form.siteLocation = this.user.siteLocation ? this.user.siteLocation : '';
    form.website = this.user.website ? this.user.website : '';
    form.about = this.user.about;
    form.takesCustomOrders = this.user.takesCustomOrders ? this.user.takesCustomOrders : '';
    this.userForm.setValue(form);
  }

}
