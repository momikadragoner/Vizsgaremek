import { Component, OnInit } from '@angular/core';
import {
  faEdit,
  faMapMarkerAlt,
  faTrash,
} from '@fortawesome/free-solid-svg-icons';
import { Address, AddressService } from 'src/app/services/address.service';

@Component({
  selector: 'app-address',
  templateUrl: './address.component.html',
  styleUrls: ['./address.component.scss'],
})
export class AddressComponent implements OnInit {
  faTrash = faTrash;
  faEdit = faEdit;
  faMapMarkerAlt = faMapMarkerAlt;

  alertOpen: boolean = false;
  addressOpen: boolean = false;
  addresses: Address[] = [new Address()];
  selectedAddress: Address = new Address();

  constructor(private addressService: AddressService) {
    addressService.getAddress().subscribe({
      next: (data) => {
        this.addresses = [...data];
      },
    });
  }

  openEditModal(id: number) {
    this.selectedAddress = this.addresses.filter((x) => x.addressId == id)[0];
    this.addressOpen = true;
  }

  openDeleteModal(id: number) {
    this.selectedAddress = this.addresses.filter((x) => x.addressId == id)[0];
    this.alertOpen = true;
  }

  deleteAddress($event: any) {
    $event.preventDeafult();
  }

  newAddress($event: any) {
    $event.preventDeafult();
    this.addressOpen = true;
  }

  ngOnInit(): void {}
}
