import { Component, EventEmitter, Input, OnChanges, OnInit, Output } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { faEnvelope, faLink, faLocationArrow, faCalendarAlt, faCamera } from '@fortawesome/free-solid-svg-icons';
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

  @Input() user: User = new User();
  @Output() modalState = new EventEmitter<boolean>();
  @Output() userChange = new EventEmitter<User>();

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
    this.userService.updateUser(this.user).subscribe({
      next: () => {
        this.userChange.emit(this.user);
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
