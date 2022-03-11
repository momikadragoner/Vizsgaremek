export class Message {
  /**
   *
   */
  constructor(
    public messageId: number = 0,
    public contactId: number = 0,
    public username: string = '',
    public message: string = '',
    public recived: boolean = false,
    public sentAt: Date = new Date()
  ) {}
}
export const messages = [
  new Message(
    0,
    4,
    'lajcsi',
    'Nullam vehicula lacus eu!',
    true,
    new Date(2021, 11, 5)
  ),
  new Message(1, 4, 'lajcsi', 'Aenean rutrum?', true, new Date(2021, 11, 5)),
  new Message(
    2,
    4,
    'lajcsi',
    'Mauris porttitor ex eget nibh',
    true,
    new Date(2021, 11, 5)
  ),
  new Message(
    3,
    4,
    'lajcsi',
    'Phasellus rutrum dolor vitae arcu rutrum, at suscipit neque laoreet.',
    false,
    new Date(2021, 11, 5)
  ),
  new Message(
    4,
    4,
    'lajcsi',
    'Enim et odio  nibh',
    true,
    new Date(2021, 11, 5)
  ),
  new Message(
    5,
    4,
    'lajcsi',
    'Enim et odio  nibh',
    true,
    new Date(2021, 11, 5)
  ),
  new Message(
    6,
    4,
    'lajcsi',
    'Enim et odio  nibh',
    true,
    new Date(2021, 11, 5)
  ),
  new Message(
    7,
    4,
    'lajcsi',
    'Aliquam odio tortor, condimentum nec.',
    false,
    new Date(2021, 11, 5)
  ),
  new Message(
    8,
    4,
    'lajcsi',
    'Aliquam odio tortor, condimentum nec.',
    false,
    new Date(2021, 11, 5)
  ),
  new Message(
    9,
    4,
    'lajcsi',
    'Aliquam odio tortor, condimentum nec.',
    false,
    new Date(2021, 11, 5)
  ),
];

class Contact {
  /**
   *
   */
  constructor(
    public id: number,
    public name: string,
    public profileImgUrl: string,
    public lastMessage: string
  ) {}
}
export const contactList = [
  new Contact(4, 'Széles Lajos', '', 'Szia'),
  new Contact(
    5,
    'Szekszárdi Katalin',
    'assets/profilepic2.jpg',
    'Elnézést, rende...'
  ),
  new Contact(6, 'Nagy Márta', '', ''),
];
