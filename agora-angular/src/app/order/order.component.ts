import { Component, OnInit } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { Address, AddressService } from '../services/address.service';
import { User, UserService } from '../services/user.service';
import { Auth } from '../services/auth';
import { faChevronLeft, faChevronRight, faSpinner } from '@fortawesome/free-solid-svg-icons';
import { Router } from '@angular/router';
import { pairwise, startWith } from 'rxjs';

@Component({
  selector: 'app-order',
  templateUrl: './order.component.html',
  styleUrls: ['./order.component.scss']
})
export class OrderComponent implements OnInit {

  currentUser: Auth = Auth.currentUser;
  userInfo: User = new User();
  addresses?: Address[];
  emptyAddress: Address = new Address();
  selectedProfile?: Address;
  modalOpen: boolean = false;

  faSpinner = faSpinner;

  constructor(
    private addressService: AddressService,
    private userService: UserService
  ) {
    userService.getUser().subscribe({
      next: data => {
        this.userInfo = { ...data };
      }
    });
    addressService.getAddress().subscribe({
      next: data => {
        if (data[0]) {
          this.addresses = [...data];
        }
      }
    });
  }

  ngOnInit(): void {
    // this.addressForm.valueChanges
    //   // .subscribe(()=>{
    //   //   if (!this.addresses) return;
    //   //   if (this.selectedProfil != undefined) {
    //   //     this.selectedProfil = new Address();
    //   //     console.log(this.selectedProfil);
    //   //   }
    //   // });
    //   .pipe(startWith(null), pairwise())
    //   .subscribe(([prev, next]: [any, any]) => {
    //     if (!this.addresses) return;
    //     if (!this.selectedProfil) return;
    //     if (next == this.addresses[0]) return;
    //     console.log('PREV', prev);
    //     console.log('NEXT', next);
    //   });
  }

}
