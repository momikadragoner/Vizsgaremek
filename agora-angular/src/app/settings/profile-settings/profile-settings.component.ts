import { Component, OnInit } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { faSave, faSpinner } from '@fortawesome/free-solid-svg-icons';
import { User, UserService } from 'src/app/services/user.service';

@Component({
  selector: 'app-profile-settings',
  templateUrl: './profile-settings.component.html',
  styleUrls: ['./profile-settings.component.scss'],
})
export class ProfileSettingsComponent implements OnInit {
  faSpinner = faSpinner;
  faSave = faSave;

  contactLoading = false;
  passwordLoading = false;

  user: User = new User();

  contactForm = this.fb.group({
    phone: [this.user.phone],
    email: [this.user.email, Validators.required],
  });

  passwordForm = this.fb.group({
    passwordEmail: ['', Validators.required],
    password: ['', Validators.required],
    newPassword: ['', Validators.required],
  });

  constructor(private userService: UserService, private fb: FormBuilder) {
    userService.getUser().subscribe({
      next: (data) => {
        this.user = { ...data };
        let form = this.contactForm.value;
        form.phone = this.user.phone;
        form.email = this.user.email;
        this.contactForm.setValue(form);
      },
    });
  }

  saveContact($event: any) {
    $event.preventDeafult();
    this.contactLoading = true;
    let updatedUser: User = this.user;
    let form = this.contactForm.value;
    updatedUser.email = form.email;
    updatedUser.phone = form.phone;
    this.userService.updateUser(updatedUser).subscribe({
      next: () => {
        this.contactLoading = false;
      },
    });
  }

  savePassword($event: any) {
    $event.preventDeafult();
  }

  ngOnInit(): void {}
}
